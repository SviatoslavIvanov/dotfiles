{ ... }:

{
  fonts.fontconfig.enable = true;

  xdg.configFile."fontconfig/conf.d/10-nix-fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <match target="pattern">
        <test qual="any" name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>JetBrainsMono Nerd Font Mono</string>
          <string>MonaspiceNe Nerd Font Mono</string>
        </edit>
      </match>

      <match target="pattern">
        <test qual="any" name="family">
          <string>JetBrainsMono Nerd Font Mono</string>
        </test>
        <edit name="family" mode="append" binding="strong">
          <string>MonaspiceNe Nerd Font Mono</string>
          <string>Apple Color Emoji</string>
        </edit>
      </match>

      <match target="font">
        <test name="family" compare="eq">
          <string>monospace</string>
        </test>
        <edit name="antialias" mode="assign">
          <bool>true</bool>
        </edit>
        <edit name="hinting" mode="assign">
          <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
          <const>hintslight</const>
        </edit>
        <edit name="rgba" mode="assign">
          <const>rgb</const>
        </edit>
        <edit name="lcdfilter" mode="assign">
          <const>lcddefault</const>
        </edit>
      </match>
    </fontconfig>
  '';
}
