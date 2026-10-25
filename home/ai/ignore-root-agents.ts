import { Plugin } from "@opencode/plugin"
import { readFile, stat } from "node:fs/promises"
import { homedir } from "node:os"
import path from "node:path"

// OpenCode has no native option to skip only the project's root-level
// AGENTS.md (OPENCODE_DISABLE_PROJECT_CONFIG also drops unrelated project
// config). Instead, strip that one instruction from the final system prompt.
//
// By the time the `context` hook runs, the prompt parts are already merged, so
// a system part is not necessarily one instruction, and the root block has no
// reliable end marker (its own content may contain "Instructions from:"). So
// match the exact text upstream generates:
//   `Instructions from: ${path.resolve(file)}\n${fileContents}`
// re-reading the exact root file, and remove only exact header + full contents
// at a line start and ending at a line end / string end.
//
// WARNING (known gap): OpenCode V2 plugins cannot read the merged config (no
// config hook or config API on the plugin context), so explicit `instructions`
// opt-ins are sourced from plugin option `instructions` plus the config files
// OpenCode itself reads (see loadInstructions). Remote/managed or other
// V2-only config sources are invisible here. Any source that exists but cannot
// be read or parsed is treated as an opt-in (fail closed: keep root AGENTS.md).
//
// The host supplies `@opencode/plugin` at runtime (the installed OpenCode's
// own version); this plugin directory needs no package.json or node_modules.

const CONFIG_NAMES = ["opencode.json", "opencode.jsonc"]

// Strip // and /* */ comments and trailing commas, outside strings only.
function parseJsonc(text: string): unknown {
  let out = ""
  let i = 0
  const skipTrivia = (from: number) => {
    let j = from
    while (j < text.length) {
      if (/\s/.test(text[j]!)) j++
      else if (text[j] === "/" && text[j + 1] === "/") while (j < text.length && text[j] !== "\n") j++
      else if (text[j] === "/" && text[j + 1] === "*") {
        const end = text.indexOf("*/", j + 2)
        j = end === -1 ? text.length : end + 2
      } else break
    }
    return j
  }
  while (i < text.length) {
    const c = text[i]!
    if (c === '"') {
      let j = i + 1
      while (j < text.length && text[j] !== '"') j += text[j] === "\\" ? 2 : 1
      out += text.slice(i, j + 1)
      i = j + 1
    } else if (c === "/" && (text[i + 1] === "/" || text[i + 1] === "*")) {
      i = skipTrivia(i)
    } else if (c === ",") {
      const next = text[skipTrivia(i + 1)]
      if (next !== "}" && next !== "]") out += c
      i++
    } else {
      out += c
      i++
    }
  }
  return JSON.parse(out)
}

type Source = { instructions: unknown[]; unreadable: boolean }

const within = (child: string, parent: string) => {
  const rel = path.relative(parent, child)
  return rel === "" || (!rel.startsWith("..") && !path.isAbsolute(rel))
}

const exists = (file: string) =>
  stat(file).then(
    () => true,
    () => false,
  )

export default Plugin.define({
  id: "ignore-root-agents",
  async setup(ctx) {
    const configHome = process.env.XDG_CONFIG_HOME
    const globalDir = path.resolve(configHome ? configHome : path.join(homedir(), ".config"), "opencode")
    const globalFile = path.resolve(globalDir, "AGENTS.md")

    // ctx.location is the plugin instance's location, not every session's, so
    // resolve the root per session: the plugin's project directory when the
    // session lives inside it, otherwise the nearest ancestor with a `.git`
    // entry (a linked worktree has a `.git` file), else the session directory.
    const resolveScope = async (sessionID: unknown) => {
      let directory = path.resolve(ctx.location.directory)
      try {
        const session = await ctx.session.get({ sessionID: sessionID as never })
        const sessionDir = (session as { location?: { directory?: string } } | undefined)?.location?.directory
        if (sessionDir) directory = path.resolve(sessionDir)
      } catch {
        // fall back to the plugin location
      }
      const project = path.resolve(ctx.location.project.directory)
      if (project !== path.parse(project).root && within(directory, project)) return { directory, root: project }
      for (let dir = directory; ; dir = path.dirname(dir)) {
        if (await exists(path.join(dir, ".git"))) return { directory, root: dir }
        if (path.dirname(dir) === dir) return { directory, root: directory }
      }
    }

    const hasGlob = (s: string) => /[*?[\]{}]/.test(s)
    const globMatch = (pattern: string, target: string) => {
      try {
        return new Bun.Glob(pattern).match(target)
      } catch {
        return false
      }
    }

    const requestsRoot = (entry: unknown, directory: string, root: string) => {
      if (typeof entry !== "string" || !entry) return false
      if (entry.startsWith("http://") || entry.startsWith("https://")) return false
      const rootFile = path.resolve(root, "AGENTS.md")
      const expanded = entry.startsWith("~/") ? path.join(homedir(), entry.slice(2)) : entry

      if (path.isAbsolute(expanded)) {
        // Upstream takes the dirname literally and globs only the basename.
        if (path.resolve(path.dirname(expanded)) !== path.dirname(rootFile)) return false
        return globMatch(path.basename(expanded), path.basename(rootFile))
      }

      let pattern = expanded.split(path.sep).join("/")
      while (pattern.startsWith("./")) pattern = pattern.slice(2)
      const glob = hasGlob(pattern)

      let ancestor = directory
      while (true) {
        if (glob) {
          if (globMatch(pattern, path.relative(ancestor, rootFile).split(path.sep).join("/"))) return true
        } else if (path.resolve(ancestor, expanded) === rootFile) {
          return true
        }
        if (ancestor === root) break
        const parent = path.dirname(ancestor)
        if (parent === ancestor) break
        ancestor = parent
      }
      return false
    }

    const readConfigText = (text: string, into: Source) => {
      try {
        const parsed = parseJsonc(text) as { instructions?: unknown } | null
        const instructions = parsed?.instructions
        if (Array.isArray(instructions)) into.instructions.push(...instructions)
        else if (instructions !== undefined) into.unreadable = true
      } catch {
        into.unreadable = true
      }
    }
    const readConfigFile = async (file: string, into: Source) => {
      let text: string
      try {
        text = await readFile(file, "utf8")
      } catch (error) {
        const code = (error as NodeJS.ErrnoException)?.code
        if (code !== "ENOENT" && code !== "ENOTDIR") into.unreadable = true
        return
      }
      readConfigText(text, into)
    }

    // Re-read on every request so config edits are observed, as before.
    const loadInstructions = async (directory: string, root: string): Promise<Source> => {
      const source: Source = { instructions: [], unreadable: false }
      const options = ctx.options?.instructions
      if (Array.isArray(options)) source.instructions.push(...options)

      const files: string[] = []
      for (const name of CONFIG_NAMES) files.push(path.join(globalDir, name))
      if (process.env.OPENCODE_CONFIG) files.push(path.resolve(process.env.OPENCODE_CONFIG))
      for (let ancestor = directory; ; ancestor = path.dirname(ancestor)) {
        for (const name of CONFIG_NAMES) {
          files.push(path.join(ancestor, name), path.join(ancestor, ".opencode", name))
        }
        if (ancestor === root || path.dirname(ancestor) === ancestor) break
      }
      if (process.env.OPENCODE_CONFIG_DIR) {
        for (const name of CONFIG_NAMES) files.push(path.join(path.resolve(process.env.OPENCODE_CONFIG_DIR), name))
      }
      for (const file of files) await readConfigFile(file, source)
      if (process.env.OPENCODE_CONFIG_CONTENT) readConfigText(process.env.OPENCODE_CONFIG_CONTENT, source)
      return source
    }

    await ctx.session.hook("context", async (event) => {
      const { directory, root } = await resolveScope(event.sessionID)
      const rootFile = path.resolve(root, "AGENTS.md")
      if (rootFile === globalFile) return
      const source = await loadInstructions(directory, root)
      if (source.unreadable || source.instructions.some((entry) => requestsRoot(entry, directory, root))) return
      let content: string
      try {
        content = await readFile(rootFile, "utf8")
      } catch {
        return
      }
      if (!content) return

      const block = `Instructions from: ${rootFile}\n${content}`
      for (let n = 0; n < event.system.length; n++) {
        const part = event.system[n]!
        const text = part.text
        let result = ""
        let pos = 0
        let from = 0
        while (true) {
          const idx = text.indexOf(block, from)
          if (idx === -1) break
          const end = idx + block.length
          const startOk = idx === 0 || text[idx - 1] === "\n"
          const endOk = end === text.length || text[end] === "\n"
          if (startOk && endOk) {
            result += text.slice(pos, idx)
            pos = end
            from = end
          } else {
            from = idx + 1
          }
        }
        // Spread keeps cache/metadata and any other part fields.
        if (pos > 0) event.system[n] = { ...part, text: result + text.slice(pos) }
      }
    })
  },
})
