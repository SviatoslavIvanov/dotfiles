{
  description = "svyat's nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    pi-src = {
      url = "github:earendil-works/pi/v1.5.0";
      flake = false;
    };

    # Agent skills: release tags where upstream publishes them, otherwise the default branch.
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };

    playwright-cli = {
      url = "github:microsoft/playwright-cli/v0.1.23";
      flake = false;
    };

    sentry-plugin-claude = {
      url = "github:getsentry/plugin-claude/v1.4.6";
      flake = false;
    };

    # 3.1 needs FastMCP 4, which nixpkgs lacks; upstream builds it on its own nixpkgs pin.
    mcp-nixos.url = "github:utensils/mcp-nixos/v3.1.0";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-fsh = {
      url = "github:catppuccin/zsh-fsh";
      flake = false;
    };

    dotfiles-private = {
      url = "git+ssh://git@github.com/SviatoslavIvanov/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nix-homebrew,
      stylix,
      catppuccin,
      dotfiles-private,
      ...
    }:
    let
      system = "aarch64-darwin";
      hostname = "svyat-mac";
      username = "ivsv";
      homeDirectory = "/Users/${username}";
      dotfilesDir = "${homeDirectory}/Developer/github.com/SviatoslavIvanov/dotfiles";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;
      packages.${system}.nixfmt = pkgs.nixfmt;

      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit
            inputs
            username
            hostname
            homeDirectory
            ;
        };
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./modules/darwin.nix
          stylix.darwinModules.stylix
          dotfiles-private.darwinModules.default

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
              autoMigrate = true;
            };
          }

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit
                  inputs
                  username
                  system
                  homeDirectory
                  dotfilesDir
                  ;
              };
              sharedModules = [
                stylix.homeModules.stylix
                catppuccin.homeModules.catppuccin
                dotfiles-private.homeModules.default
                { stylix.overlays.enable = false; }
              ];
              users.${username} = import ./modules/home.nix;
            };
          }
        ];
      };

      checks.${system}.darwin = self.darwinConfigurations.${hostname}.system;
    };
}
