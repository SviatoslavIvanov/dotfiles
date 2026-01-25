{
  description = "svyat's nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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

    dotfiles-private = {
      url = "git+ssh://git@github.com/IvanovSvyatoslav/dotfiles-private";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, nix-homebrew, stylix, ... }:
    let
      system = "aarch64-darwin";
      hostname = "svyat-mac";
      username = "ivsv";
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./modules/darwin.nix
          stylix.darwinModules.stylix

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
              extraSpecialArgs = { inherit inputs username; };
              sharedModules = [ stylix.homeModules.stylix ];
              users.${username} = import ./modules/home.nix;
            };
          }
        ];
      };
    };
}
