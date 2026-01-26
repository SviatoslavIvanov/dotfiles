{ ... }:

{
  # FontConfig для fallback шрифтов
  # Когда Monaspace не содержит символ (например, кириллицу),
  # система автоматически использует следующий шрифт из списка
  fonts.fontconfig.enable = true;

  xdg.configFile."fontconfig/conf.d/10-nix-fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Fallback для моноширинных шрифтов -->
      <match target="pattern">
        <test qual="any" name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>MonaspiceNe Nerd Font</string>
          <string>Iosevka Nerd Font</string>
          <string>JetBrainsMono Nerd Font</string>
          <string>Menlo</string>
        </edit>
      </match>

      <!-- Fallback для Monaspace конкретно -->
      <match target="pattern">
        <test qual="any" name="family">
          <string>MonaspiceNe Nerd Font</string>
        </test>
        <edit name="family" mode="append" binding="strong">
          <string>Iosevka Nerd Font</string>
          <string>JetBrainsMono Nerd Font</string>
          <string>Menlo</string>
          <string>Apple Color Emoji</string>
        </edit>
      </match>

      <!-- Настройки рендеринга для всех моноширинных шрифтов -->
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
