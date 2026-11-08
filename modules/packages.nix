{ pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils
    curl
    wget
    ripgrep
    fd
    jq
    yq
    sd
    ouch
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
    actionlint
    djvulibre
    _7zz
    plantuml
    openssh
    shellcheck
    ffmpeg
    poppler-utils
    tesseract
  ];

  programs.btop.enable = true;
}
