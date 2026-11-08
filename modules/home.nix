{
  config,
  inputs,
  lib,
  ...
}:

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
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    sessionPath = [ "/Library/TeX/texbin" ];
  };

  xdg.enable = true;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # The upstream agenix agent currently emits two negated KeepAlive
  # conditions. Keep only SuccessfulExit so launchd retries failed activation
  # (for example while the machine identity is unavailable), then stops after
  # the first successful run. Throttle retries to avoid a tight failure loop.
  launchd.agents."activate-agenix".config = {
    KeepAlive = lib.mkForce { SuccessfulExit = false; };
    ThrottleInterval = 30;
  };
}
