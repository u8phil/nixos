{ config, pkgs, ... }:
let
  dsf = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
  dsfPager = "${dsf} | ${pkgs.less}/bin/less --tabs=4 -RF";
in
{
  # Installs diff-so-fancy; Git wiring is managed explicitly below.
  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = false;
  };

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

    settings = {
      core = {
        preloadIndex = true;
        # Highlights whitespace problems in diffs; not a pre-commit policy.
        whitespace = "trailing-space,space-before-tab";
      };

      # advice.pushNonFastForward is not a current key; use the two
      # supported non-fast-forward keys instead.
      advice = {
        addEmptyPathspec = false;
        statusHints = false;
        pushNonFFCurrent = false;
        pushNonFFMatching = false;
      };

      init.defaultBranch = "master";

      status = {
        branch = true;
        showStash = true;
        showUntrackedFiles = "all";
      };

      diff = {
        unified = 2;
        renames = "copies";
        interHunkContext = 10;
      };

      # Keep +/- markers in displayed output.
      "diff-so-fancy" = {
        markEmptyLines = false;
        stripLeadingSymbols = false;
      };

      pager = {
        diff = dsfPager;
        show = dsfPager;
        branch = false;
        tag = false;
      };

      interactive = {
        diffFilter = "${dsf} --patch";
        singleKey = true;
      };

      commit = {
        verbose = true;
        template = "${config.xdg.configHome}/git/template";
      };

      push = {
        autoSetupRemote = true;
        default = "simple";
        followTags = false;
      };

      pull.rebase = true;

      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };

      # Reuse recorded conflict resolutions; they stay unstaged for review.
      rerere = {
        enabled = true;
        autoUpdate = false;
      };

      log = {
        abbrevCommit = true;
        graphColors = "cyan,yellow,magenta,green,blue,red";
      };

      # Two content lines (hash/author/age/decorations, then subject) and a
      # trailing blank separator line.
      pretty.fancy = "format:%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %C(auto)%D%C(reset)%n%s%n";

      color = {
        ui = "auto";
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red";
          new = "green";
          whitespace = "red reverse";
        };
        decorate = {
          HEAD = "yellow bold";
          branch = "green";
          remoteBranch = "cyan";
          tag = "magenta";
          stash = "red";
        };
        branch = {
          current = "yellow bold";
          local = "green";
          remote = "cyan";
        };
      };

      branch.sort = "-committerdate";
      tag.sort = "-taggerdate";

      url."https://github.com/".insteadOf = "gh:";
    };
  };

  xdg.configFile."git/template".text = ''
    # Conventional commit prefixes (optional):
    #   feat:     a new feature
    #   fix:      a bug fix
    #   docs:     documentation only changes
    #   refactor: code change that neither fixes a bug nor adds a feature
    #   perf:     a change that improves performance
    #   test:     adding or correcting tests
    #   build:    build system or dependency changes
    #   ci:       CI configuration changes
    #   chore:    other maintenance changes
    #   revert:   revert a previous commit
    #
    # Keep the subject concise and in the imperative mood.
    # Leave a blank line between the subject and the body.
    # Use the optional body to explain why the change was made.
  '';

  xdg.configFile."fish/conf.d/git-aliases.fish".text = ''
    if status is-interactive
      alias gs 'git status --short'
      alias gd 'git diff'
      alias ga 'git add'
      alias gap 'git add --patch'
      alias gds 'git diff --staged'
      alias gc 'git commit'
      alias gcl 'git clone'
      alias gi 'git init'
      alias gp 'git push'
      alias gu 'git pull'
      alias gl 'git log --all --graph --pretty=fancy'
      alias gb 'git branch'
      alias gt 'git tag'
    end
  '';
}
