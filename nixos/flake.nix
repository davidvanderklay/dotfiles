{
  description = "My NixOS and Portable Home Flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode.url = "github:anomalyco/opencode";
  };

  outputs =
    {
      self,
      nixpkgs,
      noctalia,
      nix-gaming,
      nix-darwin,
      home-manager,
      nixvim,
      lanzaboote,
      aagl,
      opencode,
      ...
    }@inputs:
    {

      darwinConfigurations."eth0" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook/default.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "before-nix";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
            home-manager.users.geolan = {
              imports = [ ./modules/home ];
              mymod.home = {
                core = {
                  enable = true;
                  homeDirectory = "/Users/geolan";
                };
                nixvim.enable = true;
              };
            };
          }
        ];
      };

      nixosConfigurations = {

        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            lanzaboote.nixosModules.lanzaboote
            aagl.nixosModules.default
            ./hosts/desktop/default.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
              home-manager.users.geolan = import ./profiles/linux-desktop.nix;
            }
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            aagl.nixosModules.default
            ./hosts/laptop/default.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
              home-manager.users.geolan = import ./profiles/linux-desktop.nix;
            }
          ];
        };
      };

      homeConfigurations = {

        "mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            nixvim.homeModules.nixvim
            ./modules/home
            {
              mymod.home = {
                core = {
                  enable = true;
                  userName = "geolan";
                  homeDirectory = "/Users/geolan";
                };
                nixvim.enable = true;
              };
              home.stateVersion = "25.11";
            }
          ];
        };

        "generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [
            nixvim.homeModules.nixvim
            ./modules/home
            {
              mymod.home = {
                core = {
                  enable = true;
                  userName = "van";
                  homeDirectory = "/home/van";
                };
                nixvim.enable = true;
              };
              home.stateVersion = "25.11";
              targets.genericLinux.enable = true;
            }
          ];
        };
      };
    };
}
