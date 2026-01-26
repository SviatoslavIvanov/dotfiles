{ pkgs, ... }:

let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "e07bf41442a7f6fdd003069f380e1ae469a86211";
    hash = "sha256-aC8DUZpzNHEf9MW3tX3XcDYY/mWClAHkw+nZaxDQHp8=";
  };
in
{
  home.packages = with pkgs; [
    coreutils
    curl
    wget
    ripgrep
    fd
    tree
    jq
    yq
    sd
    ouch
    neovim
    mise
    tokei
    httpie
    lazydocker
    ansible
    btop
    dust
    gnused
    glow
    agenix-cli
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    plugins = {
      git = "${yazi-plugins}/git.yazi";
      smart-enter = "${yazi-plugins}/smart-enter.yazi";
      jump-to-char = "${yazi-plugins}/jump-to-char.yazi";

      ouch = pkgs.fetchFromGitHub {
        owner = "ndtoan96";
        repo = "ouch.yazi";
        rev = "594b8a2b246633d46b03a3261c9aebd1c4b5abf3";
        hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
      };
      relative-motions = pkgs.fetchFromGitHub {
        owner = "dedukun";
        repo = "relative-motions.yazi";
        rev = "a603d9ea924dfc0610bcf9d3129e7cba605d4501";
        hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
      };
      glow = pkgs.fetchFromGitHub {
        owner = "Reledia";
        repo = "glow.yazi";
        rev = "bd3eaa58c065eaf216a8d22d64c62d8e0e9277e9";
        hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
      };
    };

    initLua = ''
      require("git"):setup()
      require("relative-motions"):setup({
        show_numbers = "relative_absolute",
        enter_mode = "first",
      })
    '';

    settings = {
      plugin.prepend_previewers = [
        { name = "*.md"; run = "glow"; }
        { mime = "application/*zip"; run = "ouch"; }
        { mime = "application/x-tar"; run = "ouch"; }
        { mime = "application/x-bzip2"; run = "ouch"; }
        { mime = "application/x-7z-compressed"; run = "ouch"; }
        { mime = "application/x-rar"; run = "ouch"; }
        { mime = "application/x-xz"; run = "ouch"; }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        { on = "l"; run = "plugin smart-enter"; desc = "Enter or open"; }
        { on = "<Enter>"; run = "plugin smart-enter"; desc = "Enter or open"; }
        { on = "f"; run = "plugin jump-to-char"; desc = "Jump to char"; }
        { on = "F"; run = "plugin jump-to-char --args=previous"; desc = "Jump to char (prev)"; }
        { on = "1"; run = "plugin relative-motions --args=1"; desc = "Move 1"; }
        { on = "2"; run = "plugin relative-motions --args=2"; desc = "Move 2"; }
        { on = "3"; run = "plugin relative-motions --args=3"; desc = "Move 3"; }
        { on = "4"; run = "plugin relative-motions --args=4"; desc = "Move 4"; }
        { on = "5"; run = "plugin relative-motions --args=5"; desc = "Move 5"; }
        { on = "6"; run = "plugin relative-motions --args=6"; desc = "Move 6"; }
        { on = "7"; run = "plugin relative-motions --args=7"; desc = "Move 7"; }
        { on = "8"; run = "plugin relative-motions --args=8"; desc = "Move 8"; }
        { on = "9"; run = "plugin relative-motions --args=9"; desc = "Move 9"; }
      ];
    };
  };
}
