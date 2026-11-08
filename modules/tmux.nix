{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 50000;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    resizeAmount = 3;
    mouse = true;
    focusEvents = true;
    prefix = "C-Space";

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    extraConfig = ''
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g status-position top
      set -g renumber-windows on

      bind -n S-Left previous-window
      bind -n S-Right next-window

      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1

      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      unbind %

      bind Space last-window
      bind x kill-pane

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };

  catppuccin.tmux.extraConfig = ''
    set -g @catppuccin_window_status_style "basic"
  '';
}
