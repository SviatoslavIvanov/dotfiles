{ pkgs, ... }:

let
  gitEmail = "66922372+SviatoslavIvanov@users.noreply.github.com";
  gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/WOifKMBKVekeC55DS/EHPM5yDxnoqQ0KlcZyBvVNU";
in
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      signing = {
        format = "ssh";
        key = "key::${gitSigningKey}";
        signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        signByDefault = true;
        allowedSigners = "${gitEmail} ${gitSigningKey}";
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        "*.swo"
        "*~"
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
      extensions = [ pkgs.gh-dash ];
      settings.git_protocol = "ssh";
    };

    lazygit = {
      enable = true;
      settings = {
        git.diffRenderers = [ { command = "delta --{{colorScheme}} --paging=never"; } ];
        os.editPreset = "zed";
      };
    };
  };
}
