{
  config,
  dotfilesDir,
  homeDirectory,
  lib,
  username,
  ...
}:

{
  imports = [
    ./stylix.nix
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./zed.nix
    ./claude-code.nix
    ./aerospace.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "24.11";

    sessionVariables = {
      DOTFILES_DIR = dotfilesDir;
      EDITOR = "nvim";
      VISUAL = "nvim";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    sessionPath = [ "/Library/TeX/texbin" ];

    file = {
      ".ansible.cfg".text = ''
        [defaults]
        forks = 20

        [ssh_connection]
        pipelining = True
      '';

      ".config/nvim/init.lua".source = ../configs/nvim-lazyvim/init.lua;
      ".config/nvim/lazyvim.json".source = ../configs/nvim-lazyvim/lazyvim.json;
      ".config/nvim/lazy-lock.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/nvim-lazyvim/lazy-lock.json";
      ".config/nvim/stylua.toml".source = ../configs/nvim-lazyvim/stylua.toml;
      ".config/nvim/lua".source = ../configs/nvim-lazyvim/lua;
      ".config/nvim-vscode".source = ../configs/nvim-vscode;
      ".config/p10k/config.zsh".source = ../configs/p10k.zsh;
    };
  };

  xdg = {
    enable = true;
    configFile."mise/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/mise/mise.toml";
    configFile."mise/mise.lock".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/mise/mise.lock";
  };

  # The upstream agenix agent currently emits two negated KeepAlive
  # conditions. Keep only SuccessfulExit so launchd retries failed activation
  # (for example while the machine identity is unavailable), then stops after
  # the first successful run. Throttle retries to avoid a tight failure loop.
  launchd.agents."activate-agenix".config = {
    KeepAlive = lib.mkForce { SuccessfulExit = false; };
    ThrottleInterval = 30;
  };

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "peach";

    bat.enable = true;
    btop.enable = true;
    delta.enable = true;
    eza.enable = true;
    fzf.enable = true;
    lazygit.enable = true;
    tmux = {
      enable = true;
      extraConfig = ''
        set -g @catppuccin_window_status_style "basic"
      '';
    };
    yazi.enable = true;

    gtk.icon.enable = false;
    cursors.enable = false;
    zed = {
      enable = true;
      icons.enable = false;
    };
  };
}
