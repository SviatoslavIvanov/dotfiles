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
      cleanup = "uninstall";
      upgrade = true;
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
