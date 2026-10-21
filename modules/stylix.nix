{ pkgs, config, ... }:

{
  stylix = {
    enable = true;
    # Application themes are managed explicitly below or by Catppuccin. An
    # allow-list prevents Stylix from emitting Linux-only GTK, Xresources,
    # Blender, gedit, Vencord, and similar files on macOS.
    autoEnable = false;
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
      "font-packages".enable = true;
      fontconfig.enable = true;

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
