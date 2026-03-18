{ ... }:
{
  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "rust";
          auto-format = false;
        }
      ];
    };

    settings = {
      theme = "base16";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
    };
  };
}
