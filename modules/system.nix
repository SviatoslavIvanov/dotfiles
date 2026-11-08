{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  user = config.system.primaryUser;
  screenshots = "${config.users.users.${user}.home}/Pictures/Screenshots";
in
{
  # Determinate Nix manages itself
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    # tmux runs outside the GUI session, where pam_tid cannot show the Touch ID prompt.
    reattach = true;
  };

  # The HM zshrc runs compinit itself; the global one doubles shell startup.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    enableBashCompletion = false;
    promptInit = "";
  };
  environment.shells = [ pkgs.zsh ];

  # systemsetup only changes the active power profile, so pin both: a brief unplug from the
  # dock must not inherit a one-minute battery sleep, while real battery use keeps a timeout.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    pmset -c displaysleep 10 sleep 0
    pmset -b displaysleep 10 sleep 30
    dscl . -create /Users/${user} UserShell /run/current-system/sw${pkgs.zsh.shellPath}
    install -d -o ${user} -g staff ${lib.escapeShellArg screenshots}
  '';

  # macOS starts every process with 256 open files; dev servers and file watchers need more.
  launchd.daemons.limit-maxfiles.serviceConfig = {
    ProgramArguments = [
      "/bin/launchctl"
      "limit"
      "maxfiles"
      "65536"
      "200000"
    ];
    RunAtLoad = true;
  };

  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    stateVersion = 5;

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

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      CustomSystemPreferences = {
        "/Library/Preferences/com.apple.SoftwareUpdate" = {
          AutomaticDownload = true;
          ConfigDataInstall = true;
          CriticalUpdateInstall = true;
        };
        "/Library/Preferences/com.apple.commerce".AutoUpdate = true;
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
        NSAutomaticWindowAnimationsEnabled = false;
      };

      screencapture.location = screenshots;
      loginwindow.GuestEnabled = false;
    };
  };
}
