{ lib, ... }:

let
  aerospaceApp = "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
in
{
  programs.aerospace = {
    enable = true;
    package = null; # installed via Homebrew for stable Accessibility permissions
    launchd.enable = false; # managed manually below (module can't handle package = null)

    settings = {

      # JankyBorders — Catppuccin Mocha colors (peach active, surface0 inactive)
      after-startup-command = [
        "exec-and-forget borders active_color=0xfffab387 inactive_color=0xff313244 width=4.0"
        # Soft workspace → monitor assignment (movable later with alt-shift-tab)
        "workspace C"
        "move-workspace-to-monitor secondary"
        "workspace M"
        "move-workspace-to-monitor secondary"
        "workspace W"
        "move-workspace-to-monitor secondary"
        "workspace E"
      ];

      # Mouse follows focus — mouse moves to focused window/monitor
      on-focus-changed = [ "move-mouse window-lazy-center" ];
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = true;

      # Clean layouts — prevents messy nested containers
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Layout defaults
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      accordion-padding = 30;

      key-mapping.preset = "qwerty";

      # Gaps
      gaps = {
        inner.horizontal = 10;
        inner.vertical = 10;
        outer.left = 10;
        outer.bottom = 10;
        outer.top = 10;
        outer.right = 10;
      };

      # Ensure homebrew bins are available for exec commands
      exec.inherit-env-vars = true;
      exec.env-vars.PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:\${PATH}";

      # ── Main mode ──
      mode.main.binding = {
        # Navigation (focus)
        alt-h = "focus --boundaries all-monitors-outer-frame left";
        alt-j = "focus --boundaries all-monitors-outer-frame down";
        alt-k = "focus --boundaries all-monitors-outer-frame up";
        alt-l = "focus --boundaries all-monitors-outer-frame right";

        # Move windows
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # Layout
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-f = "fullscreen";
        alt-shift-space = "layout floating tiling";

        # Resize
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        # Close window
        alt-q = "close";

        # Quick launch
        alt-enter = "exec-and-forget open -na Ghostty";

        # Back and forth between last two workspaces
        alt-tab = "workspace-back-and-forth";

        # Move workspace to another monitor
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        # ── Workspaces ──

        # Numbered (free / contextual)
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";

        # Semantic
        alt-b = "workspace B"; # Browser
        alt-t = "workspace T"; # Terminal
        alt-e = "workspace E"; # Editor
        alt-c = "workspace C"; # Communication
        alt-m = "workspace M"; # Media
        alt-w = "workspace W"; # Work (MM, Linear, Pritunl)

        alt-shift-b = "move-node-to-workspace B";
        alt-shift-t = "move-node-to-workspace T";
        alt-shift-e = "move-node-to-workspace E";
        alt-shift-c = "move-node-to-workspace C";
        alt-shift-m = "move-node-to-workspace M";
        alt-shift-w = "move-node-to-workspace W";

        # Modes
        alt-r = "mode resize";
        alt-shift-semicolon = "mode service";
      };

      # ── Resize mode ──
      mode.resize.binding = {
        h = "resize width -50";
        l = "resize width +50";
        j = "resize height +50";
        k = "resize height -50";
        minus = "resize smart -50";
        equal = "resize smart +50";
        enter = "mode main";
        esc = "mode main";
      };

      # ── Service mode ──
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


      # ── Auto-assign apps to workspaces ──
      on-window-detected = [
        # Browser
        {
          "if".app-id = "company.thebrowser.Browser";
          run = "move-node-to-workspace B";
        }
        {
          "if".app-id = "com.google.Chrome";
          run = "move-node-to-workspace B";
        }

        # Terminal
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = "move-node-to-workspace T";
        }

        # Editor
        {
          "if".app-id = "dev.zed.Zed";
          run = "move-node-to-workspace E";
        }
        {
          "if".app-id = "com.todesktop.230313mzl4w4u92";
          run = "move-node-to-workspace E";
        }

        # Communication
        {
          "if".app-id = "ru.keepcoder.Telegram";
          run = "move-node-to-workspace C";
        }
        {
          "if".app-id = "com.hnc.Discord";
          run = "move-node-to-workspace C";
        }
        {
          "if".app-id = "org.whispersystems.signal-desktop";
          run = "move-node-to-workspace C";
        }
        {
          "if".app-id = "net.whatsapp.WhatsApp";
          run = "move-node-to-workspace C";
        }

        # Media
        {
          "if".app-id = "com.spotify.client";
          run = "move-node-to-workspace M";
        }
        {
          "if".app-id = "com.tidal.desktop";
          run = "move-node-to-workspace M";
        }
        {
          "if".app-id = "com.qobuz.desktop";
          run = "move-node-to-workspace M";
        }

        # Work
        {
          "if".app-id = "com.mattermost.desktop";
          run = "move-node-to-workspace W";
        }
        {
          "if".app-id = "com.linear";
          run = "move-node-to-workspace W";
        }
        # Force float — apps that don't tile well
        {
          "if".app-id = "com.electron.pritunl";
          run = "layout floating";
        }
        {
          "if".app-name-regex-substring = "AmneziaVPN";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.calculator";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.finder";
          run = "layout floating";
        }
        {
          "if".app-id = "com.raycast.macos";
          run = "layout floating";
        }
        {
          "if".app-id = "com.1password.1password";
          run = "layout floating";
        }
        {
          "if".app-id = "us.zoom.xos";
          run = "layout floating";
        }
        {
          "if".app-id = "com.valvesoftware.steam";
          run = "layout floating";
        }
        {
          "if".app-id = "dev.kdrag0n.MacVirt";
          run = "layout floating";
        }
        {
          "if".app-id = "com.parallels.desktop.console";
          run = "layout floating";
        }
        {
          "if".app-id = "com.orbstack.OrbStack";
          run = "layout floating";
        }
      ];
    };
  };

  # Manual launchd agent pointing to Homebrew-installed binary (stable path for Accessibility)
  launchd.agents.aerospace = {
    enable = lib.mkForce true;
    config = lib.mkForce {
      Label = "org.nix-community.home.aerospace";
      Program = aerospaceApp;
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/aerospace.log";
      StandardErrorPath = "/tmp/aerospace.err.log";
    };
  };
}
