{ ... }:
{
  programs.opencode = {
    enable = true;
    tui.theme = "one-dark";
    settings = {
      mcp.github = {
        enabled = true;
        type = "local";
        command = [
          "github-mcp-server"
          "stdio"
          "--read-only"
        ];
      };
      mcp."microsoft-learn" = {
        enabled = true;
        type = "remote";
        url = "https://learn.microsoft.com/api/mcp";
      };
    };
  };
}
