{ pkgs, config, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    image = config.lib.stylix.pixel "base00";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceNe Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        terminal = 14;
        applications = 13;
      };
    };

    targets.tmux.enable = false;
    targets.zed.enable = false;
  };
}
