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

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;
      packages.${system}.nixfmt = pkgs.nixfmt;

      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username hostname; };
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
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs username system; };
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
