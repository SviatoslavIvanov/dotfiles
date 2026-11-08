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
      # Version 2 makes persistent workspaces explicit instead of inferring them
      # from workspace bindings.
      config-version = 2;
      persistent-workspaces = [
        "1"
        "2"
        "3"
        "B"
        "T"
        "E"
        "C"
        "M"
        "W"
      ];

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

        # Service mode
        alt-shift-semicolon = "mode service";
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
          "if" = "test %{app-bundle-id} = company.thebrowser.Browser";
          run = "move-node-to-workspace B";
        }
        {
          "if" = "test %{app-bundle-id} = com.google.Chrome";
          run = "move-node-to-workspace B";
        }

        # Terminal
        {
          "if" = "test %{app-bundle-id} = com.mitchellh.ghostty";
          run = "move-node-to-workspace T";
        }

        # Editor
        {
          "if" = "test %{app-bundle-id} = dev.zed.Zed";
          run = "move-node-to-workspace E";
        }
        # Communication
        {
          "if" = "test %{app-bundle-id} = ru.keepcoder.Telegram";
          run = "move-node-to-workspace C";
        }
        {
          "if" = "test %{app-bundle-id} = com.hnc.Discord";
          run = "move-node-to-workspace C";
        }
        {
          "if" = "test %{app-bundle-id} = org.whispersystems.signal-desktop";
          run = "move-node-to-workspace C";
        }
        {
          "if" = "test %{app-bundle-id} = net.whatsapp.WhatsApp";
          run = "move-node-to-workspace C";
        }

        # Media
        {
          "if" = "test %{app-bundle-id} = com.spotify.client";
          run = "move-node-to-workspace M";
        }
        # Work
        {
          "if" = "test %{app-bundle-id} = com.mattermost.desktop";
          run = "move-node-to-workspace W";
        }
        {
          "if" = "test %{app-bundle-id} = com.linear";
          run = "move-node-to-workspace W";
        }
        # Force float — apps that don't tile well
        {
          "if" = "test %{app-bundle-id} = com.electron.pritunl";
          run = "layout floating";
        }
        {
          "if" = "test %{app-name} ~= AmneziaVPN";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.apple.calculator";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.apple.finder";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.raycast.macos";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.1password.1password";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = us.zoom.xos";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.valvesoftware.steam";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = dev.kdrag0n.MacVirt";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.vmware.fusion";
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
