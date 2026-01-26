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
        name = "MonaspiceNe Nerd Font Mono";
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
        terminal = 22;
        applications = 13;
      };
    };

    targets = {
      bat.enable = false;
      fzf.enable = false;
      yazi.enable = false;
      btop.enable = false;
      neovim.enable = false;
      lazygit.enable = false;
      tmux.enable = false;
      zed.enable = false;
    };
  };
}
