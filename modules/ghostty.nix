_: {
  programs.ghostty = {
    enable = true;
    package = null;
    enableZshIntegration = false;

    settings = {
      auto-update = "check";

      font-thicken = true;
      font-family = [
        "MonaspiceNe Nerd Font Mono"
        "JetBrainsMono Nerd Font Mono"
      ];
      font-size = 22;
      font-feature = map (n: "ss0${toString n}") (builtins.genList (i: i + 1) 9);

      background-opacity = 0.95;
      background-blur = 20;
      window-padding-x = 8;
      window-padding-y = 8;

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "no-bell,notify";
      notify-on-command-finish-after = "30s";

      confirm-close-surface = false;
      quit-after-last-window-closed = true;

      macos-option-as-alt = true;
      shell-integration-features = "no-cursor";
    };
  };
}
