{
  inputs,
  homeDirectory,
  lib,
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

  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  power.sleep = {
    computer = "never";
    display = 10;
  };

  # `power.sleep.*` uses `systemsetup`, which only updates the active power
  # profile on current macOS. Pin both profiles explicitly: brief power loss
  # from the home dock must not turn the one-minute battery default into an
  # immediate sleep, while a real battery session still gets a safety timeout.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    pmset -c displaysleep 10 sleep 0
    pmset -b displaysleep 10 sleep 30
    dscl . -create /Users/${username} UserShell /run/current-system/sw${pkgs.zsh.shellPath}
  '';

  users.users.${username} = {
    name = username;
    home = homeDirectory;
  };

  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
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
        # Mission Control shows AeroSpace's corner-parked windows too small otherwise.
        expose-group-apps = true;
      };

      # AeroSpace focus is more stable with one Space across displays; needs a logout
      spaces.spans-displays = true;

      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
        FXPreferredViewStyle = "Nlsv";
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      CustomSystemPreferences."/Library/Preferences/com.apple.SoftwareUpdate" = {
        AutomaticDownload = true;
        ConfigDataInstall = true;
        CriticalUpdateInstall = true;
      };
      CustomSystemPreferences."com.apple.commerce".AutoUpdate = true;

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
        NSAutomaticWindowAnimationsEnabled = false;
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
      autoUpdate = false;

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
      {
        name = "FelixKratz/formulae/borders";
        trusted = true;
      }
    ];

    taps = [
      "netbirdio/tap"
      "nikitabobko/tap"
    ];

    casks = [
      {
        name = "nikitabobko/tap/aerospace";
        trusted = true;
      }
      {
        name = "netbirdio/tap/netbird-ui";
        trusted = true;
      }
      "1password"
      "claude-code@latest"
      "arc"
      "claude"
      "discord"
      "ghostty"
      "google-chrome"
      "jordanbaird-ice"
      "linear"
      "mac-mouse-fix"
      "moonlight"
      "obsidian"
      "orbstack"
      # qBittorrent 5.2.3 fails Gatekeeper (self-signed, not notarized), and
      # Homebrew disables the cask on 2026-09-01. Keep the verified current app
      # installed but unmanaged until upstream ships a Developer ID build.
      "raycast"
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
      "zed"
      "zoom"
      "homerow"
      "input-source-pro"
      "codex"
    ];

    # Pages, Numbers, and Keynote Creator Studio are intentionally retained
    # and remain managed by the App Store rather than Homebrew/mas.
  };

  # The HM zshrc runs compinit itself; the global one doubles shell startup.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    enableBashCompletion = false;
    promptInit = "";
  };
  environment.shells = [ pkgs.zsh ];
}
