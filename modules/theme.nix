{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.catppuccin) flavor accent;
  palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").${flavor}.colors;
  color = name: palette.${name}.hex;
  argb = name: "0xff${lib.removePrefix "#" (color name)}";

  monospace = {
    family = "MonaspiceNe Nerd Font Mono";
    fallback = "JetBrainsMono Nerd Font Mono";
    size = 22;
    features = map (n: "ss0${toString n}") (lib.range 1 9);
  };
in
{
  home.packages = with pkgs.nerd-fonts; [
    monaspace
    jetbrains-mono
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "peach";

    gtk.icon.enable = false;
    zed.icons.enable = false;
    zsh-syntax-highlighting.enable = false;
  };

  xdg.configFile."borders/bordersrc" = {
    executable = true;
    text = ''
      #!/bin/sh
      borders active_color=${argb accent} inactive_color=${argb "surface0"} width=4.0
    '';
  };

  programs.ghostty.settings = {
    font-family = [
      monospace.family
      monospace.fallback
    ];
    font-size = monospace.size;
    font-feature = monospace.features;
  };

  programs.zed-editor.userSettings = {
    buffer_font_family = monospace.family;
    buffer_font_fallbacks = [ monospace.fallback ];
    buffer_font_size = monospace.size;
    buffer_font_features = lib.genAttrs monospace.features (_: true);

    theme.mode = "dark";
    theme_overrides."Catppuccin ${lib.toSentenceCase flavor} (${accent})" = {
      background = color "base";
      "title_bar.background" = color "base";
      "title_bar.inactive_background" = color "base";
      "tab_bar.background" = color "base";
      "tab.inactive_background" = color "base";
      "tab.active_background" = "${color "text"}0b";
      "toolbar.background" = color "base";
      "status_bar.background" = color "base";
      "panel.background" = color "base";
      "panel.focused_border" = color "surface1";
      border = color "surface0";
      "border.variant" = color "surface0";
      "editor.active_line.background" = "${color "text"}08";
    };
  };
}
