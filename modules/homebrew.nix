{ config, inputs, ... }:

{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
  };

  homebrew = {
    enable = true;

    brews = [ "FelixKratz/formulae/borders" ];

    casks = [
      "nikitabobko/tap/aerospace"
      "netbirdio/tap/netbird-ui"
      "1password"
      "claude-code@latest"
      "claude"
      "codex"
      "discord"
      "ghostty"
      "google-chrome"
      "homerow"
      "input-source-pro"
      "jordanbaird-ice"
      "linear"
      "mac-mouse-fix"
      "moonlight"
      "obsidian"
      "orbstack"
      "raycast"
      "signal"
      "spotify"
      "steam"
      "telegram"
      "todoist-app"
      "utm"
      "visual-studio-code"
      "whatsapp"
      "zed"
      "zoom"
    ];
  };
}
