{ pkgs, ... }:

let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c591a36e7263e95497715d525e9c46c2f0a880ac";
    hash = "sha256-mWT0yF2iG9+gYEuNiffpM93POlBqY+QKdFh5jSAxYls=";
  };
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "nvim-vscode" ''
      NVIM_APPNAME=nvim-vscode exec nvim "$@"
    '')
    coreutils
    curl
    wget
    ripgrep
    fd
    jq
    yq
    sd
    ouch
    neovim
    jdk21
    tree-sitter
    tokei
    httpie
    lazydocker
    ansible
    dust
    gnused
    glow
    ragenix
    age
    nixd
    nixfmt
    statix
    deadnix
    stylua
    gitleaks
    _1password-cli
    cloudflared
    postgresql
  ];

  programs.btop.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    plugins = {
      git = {
        package = "${yazi-plugins}/git.yazi";
        setup = true;
      };
      smart-enter = "${yazi-plugins}/smart-enter.yazi";
      jump-to-char = "${yazi-plugins}/jump-to-char.yazi";

      ouch = pkgs.fetchFromGitHub {
        owner = "ndtoan96";
        repo = "ouch.yazi";
        rev = "cfe4f507ef7337c8ad4c90eef68ea91fc6694759";
        hash = "sha256-t1kUo4+YODeTG9d5Yq/vxElcmRHIebC5TRv+uDGG88c=";
      };
      relative-motions = {
        package = pkgs.fetchFromGitHub {
          owner = "dedukun";
          repo = "relative-motions.yazi";
          rev = "a603d9ea924dfc0610bcf9d3129e7cba605d4501";
          hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
        };
        setup = true;
        settings = {
          show_numbers = "relative_absolute";
          enter_mode = "first";
        };
      };
      glow = pkgs.fetchFromGitHub {
        owner = "Reledia";
        repo = "glow.yazi";
        rev = "bd3eaa58c065eaf216a8d22d64c62d8e0e9277e9";
        hash = "sha256-mzW/ut/LTEriZiWF8YMRXG9hZ70OOC0irl5xObTNO40=";
      };
    };

    settings = {
      plugin.prepend_previewers = [
        {
          url = "*.md";
          run = "glow";
        }
        {
          mime = "application/*zip";
          run = "ouch";
        }
        {
          mime = "application/x-tar";
          run = "ouch";
        }
        {
          mime = "application/x-bzip2";
          run = "ouch";
        }
        {
          mime = "application/x-7z-compressed";
          run = "ouch";
        }
        {
          mime = "application/x-rar";
          run = "ouch";
        }
        {
          mime = "application/x-xz";
          run = "ouch";
        }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter or open";
        }
        {
          on = "<Enter>";
          run = "plugin smart-enter";
          desc = "Enter or open";
        }
        {
          on = "f";
          run = "plugin jump-to-char";
          desc = "Jump to char";
        }
        {
          on = "1";
          run = "plugin relative-motions 1";
          desc = "Move 1";
        }
        {
          on = "2";
          run = "plugin relative-motions 2";
          desc = "Move 2";
        }
        {
          on = "3";
          run = "plugin relative-motions 3";
          desc = "Move 3";
        }
        {
          on = "4";
          run = "plugin relative-motions 4";
          desc = "Move 4";
        }
        {
          on = "5";
          run = "plugin relative-motions 5";
          desc = "Move 5";
        }
        {
          on = "6";
          run = "plugin relative-motions 6";
          desc = "Move 6";
        }
        {
          on = "7";
          run = "plugin relative-motions 7";
          desc = "Move 7";
        }
        {
          on = "8";
          run = "plugin relative-motions 8";
          desc = "Move 8";
        }
        {
          on = "9";
          run = "plugin relative-motions 9";
          desc = "Move 9";
        }
      ];
    };
  };
}
