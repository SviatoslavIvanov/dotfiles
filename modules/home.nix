{ username, ... }:

{
  imports = [
    ./stylix.nix
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./zed.nix
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
      ".config/nvim".source = ../configs/nvim-lazyvim;
      ".config/nvim-vscode".source = ../configs/nvim-vscode;
      ".config/p10k/config.zsh".source = ../configs/p10k.zsh;
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;

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
    zed.enable = false;
  };
}
