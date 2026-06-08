import type { Plugin } from "@opencode-ai/plugin"

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

export const GuardianPlugin: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      const tool = String(input?.tool ?? "").toLowerCase()
      if (tool !== "bash") return
      const args = output?.args
      if (!args || typeof args !== "object") return

      const command = (args as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      const isRm = /\b(rm|rmdir|unlink)\b/.test(command)
      if (!isRm) return

      for (const file of PROTECTED_FILES) {
        if (command.includes(file)) {
          ;(args as Record<string, unknown>).command = `echo '${BLOCK_MESSAGE.replace(/'/g, "'\\''")}'`
          return
        }
      }

      const tokens = tokenizeCommand(command)
      for (const token of tokens) {
        if (isProtectedWorkPath(token)) {
          ;(args as Record<string, unknown>).command = `echo '${BLOCK_MESSAGE.replace(/'/g, "'\\''")}'`
          return
        }
      }
    },
  }
}

export default GuardianPlugin
