{ pkgs, ... }:

let
  ghosttyConfig = ''
    theme = Catppuccin Mocha

    auto-update = check

    font-thicken = true
    font-family = MonaspiceNe Nerd Font Mono
    font-family = JetBrainsMono Nerd Font Mono
    font-size = 22
    font-feature = ss01
    font-feature = ss02
    font-feature = ss03
    font-feature = ss04
    font-feature = ss05
    font-feature = ss06
    font-feature = ss07
    font-feature = ss08
    font-feature = ss09
    font-feature = calt
    font-feature = liga

    background-opacity = 0.95
    background-blur = 20
    window-padding-x = 8
    window-padding-y = 8

    window-inherit-working-directory = true
    window-inherit-font-size = true

    notify-on-command-finish = unfocused
    notify-on-command-finish-action = no-bell,notify
    notify-on-command-finish-after = 30s

    confirm-close-surface = false
    quit-after-last-window-closed = true

    macos-option-as-alt = true
  '';
in
{
  # `config.ghostty` is the canonical name since Ghostty 1.2.3.
  xdg.configFile."ghostty/config.ghostty".text = ghosttyConfig;

  # Ghostty also loads the legacy macOS path after the XDG path. An old
  # auto-generated file at this location contains invalid bytes, so keep the
  # compatibility path valid and intentionally empty.
  home.file."Library/Application Support/com.mitchellh.ghostty/config" = {
    force = true;
    text = ''
      # Managed by Home Manager. See ~/.config/ghostty/config.ghostty.
    '';
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 50000;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    prefix = "C-Space";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    extraConfig = ''

      set -as terminal-features ",xterm-ghostty:RGB:clipboard"
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g status-position top
      set -g renumber-windows on
      set -s set-clipboard external

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -n S-Left previous-window
      bind -n S-Right next-window

      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1

      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      unbind %

      bind -r J resize-pane -D 3
      bind -r K resize-pane -U 3
      bind -r H resize-pane -L 3
      bind -r L resize-pane -R 3

      bind Space last-window
      bind x kill-pane

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
