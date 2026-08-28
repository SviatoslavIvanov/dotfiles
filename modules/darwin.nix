{
  pkgs,
  username,
  hostname,
  ...
}:

{
  networking = {
    computerName = "Святослав MacBook Pro";
    hostName = hostname;
    localHostName = hostname;
  };

  # Determinate Nix manages itself
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system = {
    stateVersion = 5;

    primaryUser = username;

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        show-recents = false;
        mru-spaces = false;
        minimize-to-application = true;
      };

      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
        FXPreferredViewStyle = "Nlsv";
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };

      LaunchServices.LSQuarantine = true;

      NSGlobalDomain = {
        _HIHideMenuBar = false;
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
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;

      # Cask upgrades stay explicit: Homebrew may remove the old app before a
      # new installer fails, as happened with Parallels. Keep that operation
      # visible instead of making every rebuild an implicit GUI-app upgrade:
      #   brew upgrade --cask <name>
      #
      # `cleanup = "uninstall"` would also remove apps intentionally managed
      # outside this Brewfile, so activation remains non-destructive.
      cleanup = "none";
      upgrade = false;
    };

    brews = [
      "mas"
      {
        name = "FelixKratz/formulae/borders";
        trusted = true;
      }
    ];

    taps = [
      "nikitabobko/tap"
    ];

    casks = [
      {
        name = "nikitabobko/tap/aerospace";
        trusted = true;
      }
      "1password"
      "claude-code@latest"
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
      "linear"
      "mac-mouse-fix"
      "mattermost"
      "moonlight"
      "obs"
      "obsidian"
      "ollama-app"
      "orbstack"
      # "parallels" — the current app was restored with the vendor installer
      # after an old Homebrew upgrade failure. Leave it vendor-managed until it
      # is deliberately adopted by Homebrew; VMs in ~/Parallels are separate.
      "pritunl"
      # qBittorrent 5.2.3 fails Gatekeeper (self-signed, not notarized), and
      # Homebrew disables the cask on 2026-09-01. Keep the verified current app
      # installed but unmanaged until upstream ships a Developer ID build.
      "qobuz"
      "raindropio"
      "raycast"
      "rustdesk"
      "signal"
      "spotify"
      "steam"
      "telegram"
      "todoist-app"
      "utm"
      # VIA desktop 3.0.0 is an obsolete, non-Gatekeeper-compliant wrapper.
      # Configure keyboards with the maintained WebHID app at usevia.app.
      "visual-studio-code"
      "whatsapp"
      "yaak"
      "zed"
      "zoom"
      "homerow"
      "input-source-pro"
      "skim"
      "codex"
    ];

    # App Store apps are intentionally outside the Brewfile so activation does
    # not depend on the current App Store account. They auto-update separately:
    #   Apple iWork (15.x): Pages=361309726, Numbers=361304891, Keynote=361285480
    #   1Password for Safari: 1569813296 (bundled with the 1password.app cask)
    masApps = { };
  };

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
}
