{ username, inputs, ... }:

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
    username = username;
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
      ".ssh/config".source = "${inputs.dotfiles-private}/.ssh/config";
      ".ssh/authorized_keys".source = "${inputs.dotfiles-private}/.ssh/authorized_keys";
      ".config/1Password".source = "${inputs.dotfiles-private}/.config/1Password";
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
