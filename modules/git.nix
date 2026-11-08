{ config, pkgs, ... }:

let
  gitEmail = "66922372+SviatoslavIvanov@users.noreply.github.com";
  gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/WOifKMBKVekeC55DS/EHPM5yDxnoqQ0KlcZyBvVNU";
in
{
  xdg.configFile."git/allowed_signers".text = "${gitEmail} ${gitSigningKey}\n";

  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      signing = {
        key = gitSigningKey;
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
        ".playwright-cli/"
      ];

      settings = {
        user = {
          name = "Sviatoslav Ivanov";
          email = gitEmail;
        };
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
            program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        fetch.prune = true;
        rebase.autoStash = true;
        branch.sort = "-committerdate";
        merge.conflictstyle = "zdiff3";
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        diff.algorithm = "histogram";
        core = {
          editor = "zed --wait";
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
        os.editPreset = "zed";
      };
    };
  };
}
