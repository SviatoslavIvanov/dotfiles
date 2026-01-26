{
  pkgs,
  lib,
  config,
  ...
}:

{
  xdg.configFile."fsh/catppuccin-mocha.ini".text = ''
    [base]
    default          = #cdd6f4
    unknown-token    = #f38ba8,bold
    commandseparator = #94e2d5
    redirection      = #94e2d5
    here-string-tri  = #bac2de
    here-string-text = #bac2de
    here-string-var  = #bac2de
    exec-descriptor  = none
    comment          = #6c7086
    correct-subtle   = #b4befe
    incorrect-subtle = #eba0ac
    subtle-separator = none
    subtle-bg        = none
    secondary        =
    recursive-base   = #cdd6f4

    [command-point]
    reserved-word     = #cba6f7
    subcommand        = #74c7ec
    alias             = #89b4fa
    suffix-alias      = #89b4fa
    global-alias      = #89b4fa
    builtin           = #cba6f7
    function          = #89b4fa
    command           = #89b4fa
    precommand        = #cba6f7
    hashed-command    = #89b4fa
    single-sq-bracket = #f9e2af
    double-sq-bracket = #f9e2af
    double-paren      = #a6e3a1

    [paths]
    path          = #f5e0dc
    pathseparator = #f5e0dc
    path-to-dir   = #f5e0dc
    globbing      = #f5c2e7
    globbing-ext  = none

    [brackets]
    paired-bracket  = bold
    bracket-level-1 = #f38ba8
    bracket-level-2 = #f9e2af
    bracket-level-3 = #74c7ec

    [arguments]
    single-hyphen-option   = #94e2d5
    double-hyphen-option   = #94e2d5
    back-quoted-argument   = #94e2d5
    single-quoted-argument = #a6e3a1
    double-quoted-argument = #a6e3a1
    dollar-quoted-argument = #a6e3a1
    optarg-string          = #a6e3a1
    optarg-number          = #fab387

    [in-string]
    back-dollar-quoted-argument           = #fab387
    back-or-dollar-double-quoted-argument = #fab387

    [other]
    variable             = #fab387
    assign               = none
    assign-array-bracket = none
    history-expansion    = none

    [math]
    mathvar = #f5c2e7
    mathnum = #fab387
    matherr = #f38ba8,bold

    [for-loop]
    forvar  = #cdd6f4
    fornum  = #fab387
    foroper = #89b4fa
    forsep  = #89b4fa

    [case]
    case-input       = #fab387
    case-parentheses = #9399b2
    case-condition   = #cba6f7
  '';

  programs = {
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      autosuggestion.enable = true;
      syntaxHighlighting.enable = false;
      historySubstringSearch.enable = true;
      enableCompletion = true;
      autocd = true;

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
        vim = "nvim";
        v = "nvim";
        nvim-vscode = "NVIM_APPNAME=nvim-vscode nvim";
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
        lg = "lazygit";

        d = "docker";
        dc = "docker compose";
        dcu = "docker compose up -d";
        dcd = "docker compose down";
        dps = "docker ps";
        dlg = "lazydocker";

        t = "tmux new-session -A -s";
        ta = "tmux attach";

        c = "__zoxide_z";

        cleanup = "nix-collect-garbage -d";
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
        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
          file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
        }
      ];

      initContent = lib.mkMerge [
        (lib.mkBefore ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '')
        ''
          ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

          function zvm_after_init() {
            source <(fzf --zsh)
            eval "$(atuin init zsh)"
          }

          function rebuild() {
            sudo darwin-rebuild switch --flake ~/.dotfiles "$@"
          }

          function update() {
            nix flake update --flake ~/.dotfiles && rebuild
          }

          eval "$(mise activate zsh)"

          source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
          [[ -f ~/.config/p10k/config.zsh ]] && source ~/.config/p10k/config.zsh

          zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border

          [[ -v functions[fast-theme] ]] && fast-theme XDG:catppuccin-mocha -q
        ''
      ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = false; # manual init in zvm_after_init (zsh-vi-mode resets keybindings)
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height=50%"
        "--layout=reverse"
        "--border"
      ];
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    bat.enable = true;

    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };

    atuin = {
      enable = true;
      enableZshIntegration = false; # manual init in zvm_after_init to load after fzf

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
          "^tree"
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
  };
}
