{ pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/WOifKMBKVekeC55DS/EHPM5yDxnoqQ0KlcZyBvVNU";
        signByDefault = true;
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        "*.swo"
        "*~"
        ".direnv"
        ".envrc"
        ".idea"
        ".vscode"
        "*.log"
        ".mise.local.toml"
        "**/.claude/settings.local.json"
      ];

      settings = {
        user = {
          name = "Sviatoslav Ivanov";
          email = "66922372+SviatoslavIvanov@users.noreply.github.com";
        };
        gpg = {
          format = "ssh";
          ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        fetch.prune = true;
        fetch.pruneTags = true;
        rebase.autoStash = true;
        branch.sort = "-committerdate";
        merge.conflictstyle = "diff3";
        rerere.enabled = true;
        diff.algorithm = "histogram";
        core = {
          editor = "nvim";
          ignorecase = false;
        };
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    gh = {
      enable = true;
      extensions = [
        pkgs.gh-dash
      ];
    };

    lazygit = {
      enable = true;
      settings = {
        git.pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
        os.editPreset = "nvim";
      };
    };
  };
}
