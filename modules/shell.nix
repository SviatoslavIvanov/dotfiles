{ pkgs, lib, config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
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

      rebuild = "darwin-rebuild switch --flake ~/.dotfiles";
      update = "nix flake update --flake ~/.dotfiles && rebuild";
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
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
        ZVM_CURSOR_STYLE_ENABLED=false

        function zvm_after_init() {
          source <(fzf --zsh)
        }

        eval "$(mise activate zsh)"

        source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
        [[ -f ~/.config/p10k/config.zsh ]] && source ~/.config/p10k/config.zsh

        zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
      ''
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height=50%" "--layout=reverse" "--border" ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
}
