{ pkgs, username, hostname, ... }:

{
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    optimise.automatic = true;
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  security.pam.enableSudoTouchIdAuth = true;

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
      "claude"
      "cursor"
      "discord"
      "exodus"
      "figma"
      "ghostty"
      "google-chrome"
      "iina"
      "jetbrains-toolbox"
      "jordanbaird-ice"
      "ledger-live"
      "linear-linear"
      "mac-mouse-fix"
      "moonlight"
      "obsidian"
      "ollama"
      "orbstack"
      "parallels"
      "pritunl"
      "proton-mail"
      "qbittorrent"
      "qobuz"
      "raycast"
      "rustdesk"
      "signal"
      "spotify"
      "steam"
      "tidal"
      "todoist"
      "utm"
      "via"
      "visual-studio-code"
      "whatsapp"
      "zed"
      "zoom"
      "telegram"
      "mattermost"
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
