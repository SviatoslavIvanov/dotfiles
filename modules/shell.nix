{
  pkgs,
  config,
  inputs,
  ...
}:

let
  dotfiles = config.home.sessionVariables.DOTFILES_DIR;
in
{
  xdg.configFile = {
    "mise/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/configs/mise/mise.toml";
    "mise/mise.lock".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/configs/mise/mise.lock";
  };

  programs = {
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      autosuggestion.enable = true;
      autocd = true;

      fastSyntaxHighlighting = {
        enable = true;
        theme = "${inputs.catppuccin-fsh}/themes/catppuccin-mocha.ini";
      };

      localVariables.ZVM_INIT_MODE = "sourcing";

      history = {
        size = 10000;
        save = 10000;
        path = "${config.xdg.cacheHome}/zsh/history";
        ignoreAllDups = true;
        ignoreSpace = true;
        share = true;
      };

      shellAliases = {
        cat = "bat -pp";
        v = "zed";
        lt = "eza --tree --level=2";

        rst = "exec zsh";
        cl = "reset";

        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git pull";
        gd = "git diff";
        gco = "git checkout";
        gb = "git branch";
        glog = "git log --oneline --graph --decorate";

        d = "docker";
        dc = "docker compose";
        dcu = "docker compose up";
        dcud = "docker compose up -d";
        dcd = "docker compose down";
        dps = "docker ps";
        dlg = "lazydocker";

        t = "tmux new-session -A -s";
        ta = "tmux attach";
      };

      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
        {
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initContent = ''
        # The flake ignores untracked files, and an uncommitted generation cannot be rebuilt elsewhere.
        function _dotfiles_require_clean() {
          local changes
          changes=$(git -C "$DOTFILES_DIR" status --porcelain) || return
          [[ -z $changes || -n $REBUILD_DIRTY ]] && return 0
          print -u2 "dotfiles have uncommitted changes; commit them or rerun with REBUILD_DIRTY=1:"
          print -u2 -r -- "$changes"
          return 1
        }

        function rebuild() {
          _dotfiles_require_clean && \
            nix flake archive --no-update-lock-file "$DOTFILES_DIR" >/dev/null && \
            sudo darwin-rebuild switch --flake "$DOTFILES_DIR" --no-update-lock-file "$@"
        }

        # Only the refreshed flake.lock may be uncommitted when it rebuilds.
        function update() {
          _dotfiles_require_clean && \
            nix flake update --flake "$DOTFILES_DIR" && \
            mise --cd "$DOTFILES_DIR" run lint && \
            REBUILD_DIRTY=1 rebuild
        }

        function generations() {
          sudo darwin-rebuild --list-generations "$@"
        }

        function rollback() {
          sudo darwin-rebuild switch --rollback "$@"
        }

        zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
      '';
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      historyWidget.command = "";
      defaultOptions = [
        "--height=50%"
        "--layout=reverse"
        "--border"
      ];
    };

    zoxide = {
      enable = true;
      options = [
        "--cmd"
        "c"
      ];
    };

    bat.enable = true;

    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };

    atuin = {
      enable = true;
      settings = {
        auto_sync = false;
        search_mode = "fuzzy";
        enter_accept = true;

        history_filter = [
          "^cd"
          "^c "
          "^z "
          "^ls"
          "^ll"
          "^la"
          "^l$"
          "^lt"
          "^pwd$"
          "^clear$"
          "^reset$"
          "^cl$"
          "^rst$"
          "^exit$"
          "^q$"
          "^cat "
          "^bat "
          "^echo "
          "^true$"
          "^false$"
        ];
      };
    };

    mise.enable = true;

    starship.enable = true;
  };
}
