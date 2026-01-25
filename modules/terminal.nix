{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      macos-titlebar-style = "tabs";
      macos-option-as-alt = true;
      window-padding-x = 10;
      window-padding-y = 10;
      window-save-state = "always";
      confirm-close-surface = false;
      cursor-style-blink = false;
      copy-on-select = "clipboard";
      font-feature = "calt,liga,ss01,ss02,ss03,ss04,ss06,ss07,ss08,ss09";
    };
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
      vim-tmux-navigator
      yank
      resurrect
      continuum
      catppuccin
    ];

    extraConfig = ''
      set -g @catppuccin_flavor "mocha"
      set -g @catppuccin_window_status_style "basic"

      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",xterm-256color:Tc"
      set -g status-position top
      set -g renumber-windows on
      set -g set-clipboard on

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

      set -g @continuum-restore 'on'
    '';
  };
}
