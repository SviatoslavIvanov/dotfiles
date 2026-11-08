{ lib, ... }:

let
  workspaces = [
    { name = "1"; }
    { name = "2"; }
    { name = "3"; }
    {
      name = "B";
      apps = [
        "company.thebrowser.Browser"
        "com.google.Chrome"
      ];
    }
    {
      name = "T";
      apps = [ "com.mitchellh.ghostty" ];
    }
    {
      name = "E";
      apps = [ "dev.zed.Zed" ];
    }
    {
      name = "C";
      apps = [
        "ru.keepcoder.Telegram"
        "com.hnc.Discord"
        "org.whispersystems.signal-desktop"
        "net.whatsapp.WhatsApp"
      ];
      monitor = "secondary";
    }
    {
      name = "M";
      apps = [ "com.spotify.client" ];
      monitor = "secondary";
    }
    {
      name = "W";
      apps = [ "com.linear" ];
      monitor = "secondary";
    }
  ];
  startupWorkspace = "E";

  floatingApps = [
    "com.apple.systempreferences"
    "com.apple.calculator"
    "com.apple.finder"
    "com.raycast.macos"
    "com.1password.1password"
    "us.zoom.xos"
    "com.valvesoftware.steam"
    "dev.kdrag0n.MacVirt"
    "com.vmware.fusion"
  ];

  key = ws: lib.toLower ws.name;
  appRule = run: app: {
    "if" = "test %{app-bundle-id} = ${app}";
    inherit run;
  };
in
{
  programs.aerospace = {
    enable = true;
    package = null; # installed via Homebrew for stable Accessibility permissions

    settings = {
      config-version = 2;
      persistent-workspaces = map (ws: ws.name) workspaces;

      after-startup-command = [
        "exec-and-forget borders"
      ]
      ++ lib.concatMap (ws: [
        "workspace ${ws.name}"
        "move-workspace-to-monitor ${ws.monitor}"
      ]) (lib.filter (ws: ws ? monitor) workspaces)
      ++ [ "workspace ${startupWorkspace}" ];

      # Not on-focus-changed: spurious focus jumps after auth prompts would drag the cursor
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      accordion-padding = 30;
      key-mapping.preset = "qwerty";

      gaps = {
        inner = {
          horizontal = 10;
          vertical = 10;
        };
        outer = {
          left = 10;
          bottom = 10;
          top = 10;
          right = 10;
        };
      };

      exec.inherit-env-vars = true;
      exec.env-vars.PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:\${PATH}";

      mode.main.binding = {
        alt-h = "focus --boundaries all-monitors-outer-frame left";
        alt-j = "focus --boundaries all-monitors-outer-frame down";
        alt-k = "focus --boundaries all-monitors-outer-frame up";
        alt-l = "focus --boundaries all-monitors-outer-frame right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-f = "fullscreen";
        alt-shift-space = "layout floating tiling";

        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        alt-q = "close";
        alt-enter = ''exec-and-forget osascript -e 'if application "Ghostty" is running then tell application "Ghostty" to new window' -e 'tell application "Ghostty" to activate' '';

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        alt-shift-semicolon = "mode service";

        # Not automatically-unhide-macos-hidden-apps: it unhides every app whenever any app hides itself
        cmd-h = [ ];
        cmd-alt-h = [ ];
      }
      // lib.listToAttrs (
        lib.concatMap (ws: [
          (lib.nameValuePair "alt-${key ws}" "workspace ${ws.name}")
          (lib.nameValuePair "alt-shift-${key ws}" "move-node-to-workspace ${ws.name}")
        ]) workspaces
      );

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];
      };

      on-window-detected =
        lib.concatMap (ws: map (appRule "move-node-to-workspace ${ws.name}") (ws.apps or [ ])) workspaces
        ++ map (appRule "layout floating") floatingApps;
    };
  };

  # programs.aerospace.launchd needs a Nix package, so the agent for the Homebrew app is defined here.
  launchd.agents.aerospace = {
    enable = lib.mkForce true;
    config = lib.mkForce {
      Label = "org.nix-community.home.aerospace";
      Program = "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
