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

      LaunchServices.LSQuarantine = false;
      screencapture.location = "~/Pictures/Screenshots";
      loginwindow.GuestEnabled = false;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    nerd-fonts.symbols-only
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;

      # Both of these are deliberately defensive while brew lags behind the
      # cask definitions it fetches from the API.
      #
      # upgrade = true destroyed the Parallels install: brew removed the old
      # version, failed to parse the new cask ("unknown install step: run"),
      # and the revert did not restore the backup. Any cask whose definition
      # outruns brew can do the same, so upgrades are now manual and visible:
      #   brew upgrade --cask <name>
      #
      # cleanup = "uninstall" removes anything not in the lists below, which
      # turns "comment out a cask that fails to parse" into "uninstall the
      # app". Several casks are commented out for exactly that reason, so this
      # stays "none" until they can be listed again.
      cleanup = "none";
      upgrade = false;
    };

    brews = [
      "mas"
      "powerlevel10k"
      "gemini-cli"
      "FelixKratz/formulae/borders"
    ];

    taps = [
      "nikitabobko/tap"
    ];

    casks = [
      "nikitabobko/tap/aerospace"
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
      # "obs" — temporarily disabled, same problem as the codex cask below:
      # the cask now uses the `command_wrapper` DSL method, which this brew
      # does not know, and the parse error aborts the entire bundle.
      # OBS is already installed and self-updates. Re-enable once brew catches up.
      "obsidian"
      "ollama-app"
      "orbstack"
      # "parallels" — disabled: the cask uses an install step ("run") this brew
      # does not know. Attempting the upgrade uninstalled Parallels Desktop and
      # then failed to reinstall it, so it has to be installed by hand from the
      # vendor. Re-enable once brew catches up. VMs in ~/Parallels are separate
      # from the app bundle and were unaffected.
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
      "actual"
      "homerow"
      "input-source-pro"
      "skim"
      # "codex" — temporarily disabled: nix-built brew (5.0.12-patched) doesn't
      # know the `generate_completions_from_executable` DSL method used by the
      # current codex cask. Re-enable once nix-darwin bumps brew.
      # Codex is already installed and self-updates.
    ];

    # masApps intentionally empty: brew bundle's mas integration is brittle
    # (currently in brew 5.1.10 it raises "mas installation failed" even when
    # mas + the app are clearly installed), and the bundle aborts on the first
    # failure. App Store apps auto-update on their own — manage them by hand:
    #   Apple iWork (15.x): Pages=361309726, Numbers=361304891, Keynote=361285480
    #   1Password for Safari: 1569813296 (bundled with the 1password.app cask)
    masApps = { };
  };

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
}
