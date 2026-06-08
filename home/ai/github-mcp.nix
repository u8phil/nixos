{
  ...
}:
{
  # GitHub personal access token for the GitHub MCP server. Lives only in
  # secrets/work-vpn.yaml under the `github-mcp` key. It is injected into the
  # MCP server process at runtime by the wrappers in opencode.nix and
  # claude-code.nix, which read config.sops.secrets.github-mcp.path. The token
  # therefore never lands in systemd environment.d (session-wide) nor in the
  # Nix store (only the secret's runtime path does).
  sops.secrets.github-mcp = { };
}
