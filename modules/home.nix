{ config, inputs, ... }:

{
  imports = [
    ./theme.nix
    ./hygiene.nix
    ./packages.nix
    ./yazi.nix
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./tmux.nix
    ./zed.nix
    ./agents.nix
    ./claude-code.nix
    ./codex.nix
    ./pi.nix
    ./aerospace.nix
  ];

  home = {
    stateVersion = "24.11";
    preferXdgDirectories = true;

    sessionVariables = {
      DOTFILES_DIR = "${config.home.homeDirectory}/Developer/github.com/SviatoslavIvanov/dotfiles";
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };

    sessionPath = [ "/Library/TeX/texbin" ];
  };

  xdg.enable = true;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
}
