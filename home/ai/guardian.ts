import { Plugin } from "@opencode/plugin"
import { Error as ToolError } from "@opencode/plugin/promise/tool"

const PROTECTED_FILES = [
  "devenv.local.nix",
  ".opencode/AGENTS.md",
  ".opencode",
]

const WORK_ROOT = "/home/phil/work"

const BLOCK_MESSAGE = `\
The opencode guardian plugin blocked this rm command targeting a protected path.

Protected items:
  - devenv.local.nix              (uncommitted local-override, no git backup)
  - .opencode/AGENTS.md           (opencode project instructions, no git backup)
  - .opencode/ directories        (contain critical project config)
  - /home/phil/work               (the work root itself)
  - /home/phil/work/<name>        (top-level project would destroy working tree)

Items under /home/phil/work/<name>/<inner> are NOT protected (nested content
is fine). Only the top-level entries inside work/ are safeguarded.

If you really need to delete these, do it manually outside of opencode.
These safeguards exist because the files/dirs have no git backup or are
easy to accidentally nuke with a cleanup command.`

function tokenizeCommand(cmd: string): string[] {
  const tokens: string[] = []
  const re = /(?:[^\s"']+|"[^"]*"|'[^']*')+/g
  let m: RegExpExecArray | null
  while ((m = re.exec(cmd)) !== null) {
    tokens.push(m[0])
  }
  return tokens
}

function isProtectedWorkPath(clean: string): boolean {
  let p = clean.replace(/^['"]|['"]$/g, "").replace(/\/+$/, "")
  if (p === WORK_ROOT) return true
  const prefix = WORK_ROOT + "/"
  if (p.startsWith(prefix)) {
    const rest = p.slice(prefix.length)
    if (!rest.includes("/")) return true
  }
  return false
}

function targetsProtectedPath(command: string): boolean {
  if (!/\b(rm|rmdir|unlink)\b/.test(command)) return false
  if (PROTECTED_FILES.some((file) => command.includes(file))) return true
  return tokenizeCommand(command).some(isProtectedWorkPath)
}

export default Plugin.define({
  id: "guardian",
  async setup(ctx) {
    // V2 names the command tool "shell"; "bash" is the V1 name.
    await ctx.tool.hook("execute.before", (event) => {
      const tool = String(event.tool ?? "").toLowerCase()
      if (tool !== "shell" && tool !== "bash") return
      const input = event.input
      if (!input || typeof input !== "object") return

      const command = (input as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      // Rejecting (rather than rewriting to a successful echo) surfaces the
      // reason to the model as a failed tool call.
      if (targetsProtectedPath(command)) throw new ToolError({ message: BLOCK_MESSAGE })
    })
  },
})
