{ ... }:
{
  programs.git = {
    enable = true;

    # Global gitignore (~/.config/git/ignore). Patterns without a leading
    # path component match a directory of that name at any depth.
    ignores = [
      "**/.claude/settings.local.json"
      ".cocoindex_code/"
      ".serena/"
      ".opencode/"
    ];
  };
}
