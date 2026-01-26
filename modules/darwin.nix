{ pkgs, username, hostname, ... }:

{
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix manages itself
  nix.enable = false;

  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = username;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    nerd-fonts.symbols-only
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };

    brews = [
      "mas"
      "powerlevel10k"
      "gemini-cli"
    ];

    casks = [
      "1password"
      "alt-tab"
      "amneziavpn"
      "arc"
      "balenaetcher"
      "capacities"
      "claude"
      "cursor"
      "discord"
      "figma"
      "ghostty"
      "google-chrome"
      "iina"
      "jetbrains-toolbox"
      "jordanbaird-ice"
      "linear-linear"
      "mac-mouse-fix"
      "mattermost"
      "moonlight"
      "obs"
      "obsidian"
      "ollama-app"
      "orbstack"
      "parallels"
      "pritunl"
      "qbittorrent"
      "qobuz"
      "raindropio"
      "raycast"
      "rustdesk"
      "signal"
      "spotify"
      "steam"
      "telegram"
      "tidal"
      "todoist-app"
      "utm"
      "via"
      "visual-studio-code"
      "whatsapp"
      "yaak"
      "zed"
      "zoom"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
    };

    finder = {
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv";
      FXEnableExtensionChangeWarning = false;
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
    };

    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
    };

    screencapture.location = "~/Pictures/Screenshots";
    loginwindow.GuestEnabled = false;
  };

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
}
