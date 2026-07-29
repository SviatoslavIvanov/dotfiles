{ username, ... }:

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
    ./homebrew-trust.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    file = {
      ".ansible.cfg".text = ''
        [defaults]
        forks = 20

        [ssh_connection]
        pipelining = True
      '';

      ".config/nvim/init.lua".source = ../configs/nvim-lazyvim/init.lua;
      ".config/nvim/lazyvim.json".source = ../configs/nvim-lazyvim/lazyvim.json;
      ".config/nvim/stylua.toml".source = ../configs/nvim-lazyvim/stylua.toml;
      ".config/nvim/.neoconf.json".source = ../configs/nvim-lazyvim/.neoconf.json;
      ".config/nvim/lua".source = ../configs/nvim-lazyvim/lua;
      ".config/nvim-vscode".source = ../configs/nvim-vscode;
      ".config/p10k/config.zsh".source = ../configs/p10k.zsh;
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;

  programs._1password-shell-plugins = {
    enable = true;
    plugins = [
    ];
  };

  catppuccin = {
    enable = true;
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
