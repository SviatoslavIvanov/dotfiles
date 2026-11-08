{ pkgs, ... }:

let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c591a36e7263e95497715d525e9c46c2f0a880ac";
    hash = "sha256-mWT0yF2iG9+gYEuNiffpM93POlBqY+QKdFh5jSAxYls=";
  };
  archiveMimes = [
    "application/*zip"
    "application/x-tar"
    "application/x-bzip2"
    "application/x-7z-compressed"
    "application/x-rar"
    "application/x-xz"
  ];
in
{
  programs.yazi = {
    enable = true;
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

    settings.plugin.prepend_previewers = [
      {
        url = "*.md";
        run = "glow";
      }
    ]
    ++ map (mime: {
      inherit mime;
      run = "ouch";
    }) archiveMimes;

    keymap.mgr.prepend_keymap = [
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
    ]
    ++ map (n: {
      on = toString n;
      run = "plugin relative-motions ${toString n}";
      desc = "Move ${toString n}";
    }) (builtins.genList (i: i + 1) 9);
  };
}
