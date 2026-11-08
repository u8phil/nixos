import { Plugin } from "@opencode/plugin"
import { Error as ToolError } from "@opencode/plugin/promise/tool"
import { readFile, realpath, stat } from "node:fs/promises"
import { homedir } from "node:os"
import path from "node:path"
import { fileURLToPath } from "node:url"

// Opt-in per project, default OFF. Two ways to enable (local file wins):
//  1. `<root>/.opencode/config.json`:  { "blockRootAgentFiles": true }
//     Re-read on every event (other keys ignored). A boolean here overrides 2.
//  2. Plugin option in opencode.json: plugins: [{ package, options: { blockRootAgentFiles: true } }]
//     Default for this plugin instance's own root only (nearest .git of
//     ctx.location.directory); it never applies to another repo/worktree a session
//     moves into, which must opt in via its own config.json.
// Neither set, or false = every hook is a no-op (no root file reads).
// Unreadable/invalid JSON or a non-boolean value (file or option) =
// fail-closed error. Toggling affects new requests, but prompts already containing
// root instructions need a restart / new session.
//
// Policy when enabled: the repository-root AGENTS.md and CLAUDE.md are never given
// to the model. OpenCode `instructions` config is deliberately not read, so it
// cannot switch the policy off.
//
// OpenCode has no native "skip root AGENTS.md" option, so the plugin
//  1. scrubs the exact generated block
//       `Instructions from: <path>\n<file contents>`
//     from every model-visible string (system parts, messages, nested metadata).
//     The root file is read privately; its content is only used for exact,
//     line-bounded matching (never sliced at the next marker, because the file
//     may itself contain "Instructions from:") and is never logged or put into
//     errors. Whatever still looks like a root instruction header or a
//     "The instructions from <root> changed" diff marker afterwards fails closed.
//  2. denies direct reads/edits/greps of those files in tools, shell commands
//     and prompt attachments, and re-checks the final HTTP/WebSocket payloads
//     so a later plugin cannot re-inject them.
//
// Root = nearest ancestor of the session (or shell cwd) directory holding a
// `.git` entry (directory or linked-worktree file), resolved on every call.
//
// CAVEAT: the shell guard is a best-effort token check, not a sandbox. Obfuscated
// commands, scripts, `find | xargs`, copies made through MCP servers or other
// processes can still reach the files. Nested and global rule files stay allowed.
// Old merged prompts have no authenticated per-file boundaries: a changed root
// file can be an ambiguous prefix of historical text. Start a fresh session after
// enabling this policy; do not treat this plugin as a guarantee for old history.

const NAMES = ["AGENTS.md", "CLAUDE.md"]
const PATH_KEYS = ["path", "filePath", "file_path", "filename"]
const HEADER = "Instructions from: "
const GIT_QUIET = new Set(["add", "rm", "mv", "status", "restore", "reset", "checkout", "commit"])

const missing = (error: unknown) => {
  const code = (error as NodeJS.ErrnoException | undefined)?.code
  return code === "ENOENT" || code === "ENOTDIR"
}

const exists = (file: string) =>
  stat(file).then(
    () => true,
    (error) => {
      if (missing(error)) return false
      throw error
    },
  )

const isDir = (file: string) =>
  stat(file).then(
    (s) => s.isDirectory(),
    (error) => {
      if (missing(error)) return false
      throw error
    },
  )

// realpath that tolerates a missing tail (new files, nonexistent cwd).
async function canon(file: string): Promise<string> {
  try {
    return await realpath(file)
  } catch (error) {
    if (!missing(error)) throw error
    const parent = path.dirname(file)
    return parent === file ? file : path.join(await canon(parent), path.basename(file))
  }
}

const within = (child: string, parent: string) => {
  const rel = path.relative(parent, child)
  return rel === "" || (!rel.startsWith("..") && !path.isAbsolute(rel))
}

const globMatches = (pattern: string, name: string) => {
  if (pattern.startsWith("!")) return true // cannot prove exclusion: fail closed
  try {
    return new Bun.Glob(pattern).match(name)
  } catch {
    return true
  }
}

const hasGlob = (s: string) => /[*?[\]{}]/.test(s)

const isPlain = (v: unknown): v is Record<string, unknown> => {
  if (typeof v !== "object" || v === null) return false
  const proto = Object.getPrototypeOf(v)
  return proto === Object.prototype || proto === null
}

// Rebuild plain arrays/objects with every string mapped; other values pass through.
function mapStrings(value: unknown, fn: (s: string) => string): unknown {
  if (typeof value === "string") return fn(value)
  if (Array.isArray(value)) return value.map((v) => mapStrings(v, fn))
  if (isPlain(value)) return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, mapStrings(v, fn)]))
  return value
}

function someString(value: unknown, fn: (s: string) => boolean): boolean {
  if (typeof value === "string") return fn(value)
  if (Array.isArray(value)) return value.some((v) => someString(v, fn))
  if (isPlain(value)) return Object.values(value).some((v) => someString(v, fn))
  return false
}

// Remove every complete `block` plus one adjacent separator. A block is complete
// only at a source boundary: end of text, the upstream group separator "\n\n", or
// a single "\n" directly before another `Instructions from:` header. Anything else
// (e.g. an old longer body whose first lines equal the current file) is left in
// place so the leftover header fails closed instead of being stripped partially.
function removeBlock(text: string, block: string): string {
  let from = 0
  while (true) {
    const idx = text.indexOf(block, from)
    if (idx === -1) return text
    let start = idx
    let end = idx + block.length
    const startOk = idx === 0 || text[idx - 1] === "\n"
    const endOk =
      end === text.length || text.startsWith("\n\n", end) || (text[end] === "\n" && text.startsWith(HEADER, end + 1))
    if (!startOk || !endOk) {
      from = idx + 1
      continue
    }
    if (text.startsWith("\n\n", end)) end += 2
    else if (text[end] === "\n") end += 1
    else if (end === text.length && start > 0) start -= text.slice(start - 2, start) === "\n\n" ? 2 : 1
    text = text.slice(0, start) + text.slice(end)
    from = start
  }
}

// Does `text` still contain a root header line or update/diff marker for one of `files`?
function hasMarker(text: string, files: string[]): boolean {
  for (const file of files) {
    if (text.includes(`The instructions from ${file} changed`)) return true
    const header = HEADER + file
    for (let at = text.indexOf(header); at !== -1; at = text.indexOf(header, at + 1)) {
      const end = at + header.length
      const startOk = at === 0 || text[at - 1] === "\n"
      const endOk = end === text.length || text[end] === "\n" || text[end] === "\r"
      if (startOk && endOk) return true
    }
  }
  return false
}

// Shell tokenizer: [commands][tokens]. Quotes are stripped; ; | & newline split commands.
function tokenize(command: string): string[][] {
  const commands: string[][] = []
  let tokens: string[] = []
  let token = ""
  let has = false
  let quote = ""
  const flush = () => {
    if (has) tokens.push(token)
    token = ""
    has = false
  }
  const split = () => {
    flush()
    if (tokens.length) commands.push(tokens)
    tokens = []
  }
  for (let i = 0; i < command.length; i++) {
    const c = command[i]!
    if (quote) {
      if (c === quote) quote = ""
      else if (c === "\\" && quote === '"' && i + 1 < command.length) token += command[++i]
      else token += c
    } else if (c === "'" || c === '"') {
      quote = c
      has = true
    } else if (c === "\\" && i + 1 < command.length) {
      token += command[++i]
      has = true
    } else if (c === ";" || c === "|" || c === "&" || c === "\n") split()
    else if (/\s/.test(c) || c === "<" || c === ">" || c === "(" || c === ")" || c === "`") flush()
    else {
      token += c
      has = true
    }
  }
  split()
  return commands
}

type Scope = {
  directory: string
  real: string
  files: string[] // header path variants (lexical + canonical) for root AGENTS.md / CLAUDE.md
  protectedReal: Set<string>
  enabled: boolean // project opt-in: <root>/.opencode/config.json {"blockRootAgentFiles": true}
}

// Re-read on every call. Missing file or absent key = undefined (fall back to the
// native plugin option); unparsable or non-boolean value rejects (never silently
// disables the policy).
async function projectFlag(root: string): Promise<boolean | undefined> {
  let text: string
  try {
    text = await readFile(path.join(root, ".opencode", "config.json"), "utf8")
  } catch (error) {
    if (missing(error)) return undefined
    throw new ToolError({ message: "ignore-root-agents: .opencode/config.json exists but cannot be read; fix it to continue." })
  }
  let parsed: unknown
  try {
    parsed = JSON.parse(text)
  } catch {
    throw new ToolError({ message: "ignore-root-agents: .opencode/config.json is not valid JSON; fix it to continue." })
  }
  const flag = isPlain(parsed) ? parsed.blockRootAgentFiles : undefined
  if (flag === undefined || typeof flag === "boolean") return flag
  throw new ToolError({ message: "ignore-root-agents: blockRootAgentFiles in .opencode/config.json must be a boolean." })
}

export default Plugin.define({
  id: "ignore-root-agents",
  async setup(ctx) {
    const fail = (message: string): never => {
      throw new ToolError({ message })
    }
    const restart = () =>
      fail(
        "ignore-root-agents: the user explicitly does NOT want the contents of repository-root CLAUDE.md or AGENTS.md read. " +
          "This request still contains those contents and cannot be filtered safely. Start a fresh session; do not work around the user's choice.",
      )

    // Nearest ancestor with a `.git` entry; else the plugin project when the
    // directory lies inside it; else the directory itself.
    const findRoot = async (directory: string) => {
      for (let dir = directory; ; dir = path.dirname(dir)) {
        if (await exists(path.join(dir, ".git"))) return dir
        if (path.dirname(dir) === dir) break
      }
      const project = path.resolve(ctx.location.project.directory)
      return project !== path.parse(project).root && within(directory, project) ? project : directory
    }

    const nativeOption = (): boolean | undefined => {
      const value = (ctx.options as Record<string, unknown> | undefined)?.blockRootAgentFiles
      if (value === undefined || typeof value === "boolean") return value
      return fail("ignore-root-agents: plugin option blockRootAgentFiles must be a boolean.")
    }

    const resolveScope = async (sessionID?: unknown, cwd?: string): Promise<Scope> => {
      const native = nativeOption()
      let directory = path.resolve(cwd ?? ctx.location.directory)
      if (!cwd && sessionID !== undefined) {
        try {
          const session = (await ctx.session.get({ sessionID: sessionID as never })) as
            | { location?: { directory?: string } }
            | undefined
          if (session?.location?.directory) directory = path.resolve(session.location.directory)
        } catch {
          // keep the plugin location
        }
      }
      const lexical = await findRoot(directory)
      const real = await canon(lexical)
      // Local .opencode/config.json overrides the native option; the native option
      // applies only to this plugin instance's own root, never to another repo/worktree.
      const flag = await projectFlag(real)
      const enabled =
        flag ?? (native === true && real === (await canon(await findRoot(path.resolve(ctx.location.directory)))))
      if (!enabled) return { directory, real, files: [], protectedReal: new Set(), enabled: false }

      const files: string[] = []
      const protectedReal = new Set<string>()
      for (const name of NAMES) {
        const target = await canon(path.join(real, name))
        protectedReal.add(path.join(real, name)).add(target)
        for (const variant of new Set([path.join(lexical, name), path.join(real, name), target])) files.push(variant)
      }
      return { directory, real, files, protectedReal, enabled }
    }

    const readRoot = async (scope: Scope) => {
      const contents = new Map<string, string>()
      for (const file of scope.files) {
        try {
          contents.set(file, await readFile(file, "utf8"))
        } catch (error) {
          if (!missing(error)) fail(`ignore-root-agents: cannot inspect ${path.basename(file)} (${(error as NodeJS.ErrnoException)?.code ?? "error"}).`)
        }
      }
      return contents
    }

    const scrubAll = (value: unknown, contents: Map<string, string>) =>
      mapStrings(value, (text) => {
        for (const [file, content] of contents) text = removeBlock(text, `${HEADER}${file}\n${content}`)
        return text
      })

    const assertClean = (value: unknown, scope: Scope) => {
      if (someString(value, (text) => hasMarker(text, scope.files))) restart()
    }

    const pathProtected = async (target: string, base: string, scope: Scope) =>
      scope.protectedReal.has(await canon(path.resolve(base, target)))

    // file URI (any scheme case, ?query, #fragment, `..`, symlinks) -> protected root file?
    const protectedUri = async (uri: unknown, scope: Scope) => {
      if (typeof uri !== "string") return false
      let local: string
      try {
        const url = new URL(uri)
        if (url.protocol.toLowerCase() !== "file:") return false
        url.search = ""
        url.hash = ""
        local = fileURLToPath(url)
      } catch {
        return false
      }
      return pathProtected(local, scope.directory, scope)
    }

    // Stored attachments are re-rendered as text parts carrying
    // metadata.attachment = { source: { type, uri }, name }; the block scrub cannot
    // match them, so drop the root-file parts (and media right after them) by provenance.
    const dropAttachments = async (messages: unknown, scope: Scope) => {
      if (!Array.isArray(messages)) return messages
      const out: unknown[] = []
      for (const msg of messages) {
        if (!isPlain(msg) || !Array.isArray(msg.content)) {
          out.push(msg)
          continue
        }
        const content: unknown[] = []
        let dropped = false
        let afterDropped = false
        for (const part of msg.content) {
          const meta = isPlain(part) && isPlain(part.metadata) ? part.metadata : undefined
          const attachment = meta && isPlain(meta.attachment) ? meta.attachment : undefined
          let drop = false
          if (attachment) {
            const source = isPlain(attachment.source) ? attachment.source : undefined
            const name = typeof attachment.name === "string" ? path.basename(attachment.name.split("#")[0]!) : ""
            drop = source?.type === "inline" ? NAMES.includes(name) : await protectedUri(source?.uri, scope)
          } else if (afterDropped && isPlain(part) && part.type !== "text") drop = true
          afterDropped = drop
          dropped ||= drop
          if (!drop) content.push(part)
        }
        if (!dropped) out.push(msg)
        else if (content.length) out.push({ ...msg, content })
      }
      return out
    }

    // Wire payloads: reject objects that still carry a root file's attachment provenance.
    const assertNoAttachment = async (value: unknown, scope: Scope) => {
      const uris: unknown[] = []
      const walk = (v: unknown) => {
        if (Array.isArray(v)) v.forEach(walk)
        else if (isPlain(v)) {
          const source = isPlain(v.attachment) ? v.attachment.source : undefined
          if (isPlain(source)) uris.push(source.uri)
          Object.values(v).forEach(walk)
        }
      }
      walk(value)
      for (const uri of uris) if (await protectedUri(uri, scope)) restart()
    }

    const denyFile = () =>
      fail("ignore-root-agents: the user explicitly does NOT want you to read the contents of repository-root CLAUDE.md or AGENTS.md. This is intentional, not a missing-file error. Do not retry through another tool or workaround. Nested and global instruction files remain allowed.")

    // Prompt paths: rewrite model-visible context, then fail closed on leftovers.
    const scrubRequest = async (event: any) => {
      const scope = await resolveScope(event.sessionID)
      if (!scope.enabled) return
      const contents = await readRoot(scope)
      event.system = scrubAll(event.system ?? [], contents)
      event.messages = scrubAll(await dropAttachments(event.messages ?? [], scope), contents)
      assertClean(event.system, scope)
      assertClean(event.messages, scope)
    }
    for (const name of ["context", "compaction", "generate", "title"]) await ctx.session.hook(name as never, scrubRequest as never)

    await ctx.session.hook("prompt" as never, (async (event: any) => {
      const files = event.prompt?.files
      if (!Array.isArray(files)) return
      const scope = await resolveScope(event.sessionID)
      if (!scope.enabled) return
      // Filter rather than throw: a throw in the prompt hook is a defect, not a clean rejection.
      const kept: unknown[] = []
      for (const file of files) if (!(await protectedUri(file?.uri, scope))) kept.push(file)
      if (kept.length !== files.length) event.prompt.files = kept
    }) as never)

    // Final native guards: nothing root-related may reach the wire.
    await ctx.session.hook("http.request" as never, (async (event: any) => {
      const request: Request | undefined = event.request
      if (!request || request.body === null) return
      const scope = await resolveScope(event.sessionID)
      if (!scope.enabled) return
      let body: unknown
      try {
        body = await request.clone().json()
      } catch {
        return fail("ignore-root-agents: refusing an unreadable model request body (cannot verify root instruction policy).")
      }
      assertClean(body, scope)
      await assertNoAttachment(body, scope)
    }) as never)

    await ctx.session.hook("experimental.ws.send" as never, (async (event: any) => {
      const scope = await resolveScope(event.sessionID)
      if (!scope.enabled) return
      let frame: unknown
      try {
        frame = JSON.parse(event.frame)
      } catch {
        return fail("ignore-root-agents: refusing an unreadable model WebSocket frame (cannot verify root instruction policy).")
      }
      assertClean(frame, scope)
      await assertNoAttachment(frame, scope)
    }) as never)

    // Tool guards ---------------------------------------------------------------
    const grepGuard = async (input: Record<string, unknown>, scope: Scope) => {
      const target = await canon(path.resolve(scope.directory, typeof input.path === "string" ? input.path : "."))
      if (scope.protectedReal.has(target)) denyFile()
      const names = [...scope.protectedReal].filter((p) => within(p, target))
      if (!names.length) return
      const patterns = [input.include, input.glob].filter((p): p is string => typeof p === "string" && p !== "")
      const excluded = patterns.length > 0 && patterns.every((p) =>
        names.every((n) => !globMatches(p, path.relative(target, n)) && !globMatches(p, path.basename(n))),
      )
      if (!excluded) fail("ignore-root-agents: the user explicitly does NOT want the contents of repository-root CLAUDE.md or AGENTS.md read. This search includes them. Restrict the search to a nested directory or an include glob that excludes both files; do not bypass the user's choice.")
    }

    const shellGuard = async (command: string, cwd: string) => {
      const scope = await resolveScope(undefined, cwd)
      if (!scope.enabled) return
      for (const tokens of tokenize(command)) {
        const head = path.basename(tokens[0] ?? "")
        if (head === "git" && GIT_QUIET.has(tokens.find((t, i) => i > 0 && !t.startsWith("-")) ?? "")) continue

        for (const raw of tokens) {
          const candidates = raw.startsWith("-") ? (raw.includes("=") ? [raw.slice(raw.indexOf("=") + 1)] : []) : [raw]
          for (let token of candidates) {
            if (!token) continue
            if (token.startsWith("~/")) token = path.join(homedir(), token.slice(2))
            const base = path.basename(token)
            if (hasGlob(base)) {
              const dir = await canon(path.resolve(scope.directory, path.dirname(token)))
              if (dir === scope.real && NAMES.some((n) => globMatches(base, n))) denyFile()
            } else if (await pathProtected(token, scope.directory, scope)) denyFile()
          }
        }

        // Conservative: recursive content scans of a tree containing the root files.
        const recursive =
          ["rg", "ag", "ack"].includes(head) ||
          (["grep", "egrep", "fgrep"].includes(head) && tokens.some((t) => /^-[A-Za-z]*[rR]/.test(t) || t === "--recursive"))
        if (!recursive || tokens.some((t) => /^(--(include|glob|iglob|exclude|exclude-dir|type|ignore-file)\b|-[gt]$)/.test(t))) continue
        const dirs: string[] = []
        for (const t of tokens.slice(1)) {
          if (t.startsWith("-")) continue
          const resolved = path.resolve(scope.directory, t)
          if (await isDir(resolved)) dirs.push(await canon(resolved))
        }
        if (!dirs.length) dirs.push(await canon(scope.directory))
        if (dirs.some((d) => [...scope.protectedReal].some((p) => within(p, d))))
          fail("ignore-root-agents: the user explicitly does NOT want the contents of repository-root CLAUDE.md or AGENTS.md read. This recursive scan may include them. Restrict its scope to exclude both files; do not bypass the user's choice.")
      }
    }

    await ctx.tool.hook("execute.before", (async (event: any) => {
      const tool = String(event.tool ?? "").toLowerCase()
      const input = event.input
      if (!input || typeof input !== "object") return
      const scope = await resolveScope(event.sessionID)
      if (!scope.enabled) return

      if (tool === "shell" || tool === "bash") {
        const cwd = [input.workdir, input.cwd].find((v) => typeof v === "string") as string | undefined
        if (typeof input.command === "string") await shellGuard(input.command, cwd ? path.resolve(scope.directory, cwd) : scope.directory)
        return
      }
      if (tool === "grep") return grepGuard(input, scope)
      if (tool === "glob") return // listing names does not expose contents

      for (const key of PATH_KEYS) {
        const value = input[key]
        if (typeof value === "string" && value && (await pathProtected(value, scope.directory, scope))) denyFile()
      }
      if (typeof input.patchText === "string") {
        for (const match of input.patchText.matchAll(/^\*\*\* (?:Update|Add|Delete) File: (.+)$/gm)) {
          if (await pathProtected(match[1]!.trim(), scope.directory, scope)) denyFile()
        }
      }
    }) as never)

    await ctx.shell.hook("create.before", (async (event: any) => {
      if (typeof event.command !== "string") return
      await shellGuard(event.command, event.cwd ? path.resolve(event.cwd) : path.resolve(ctx.location.directory))
    }) as never)
  },
})
