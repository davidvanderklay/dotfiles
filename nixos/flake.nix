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
      url = "github:noctalia-dev/noctalia-shell/v5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      specialArgs = { inherit inputs; };

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      nixosModules.default = import ./modules/nixos;
      homeModules.default = import ./modules/home;

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-rfc-style);

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with pkgsFor system; [
            nixfmt-rfc-style
            statix
            deadnix
          ];
        };
      });

      darwinConfigurations."eth0" = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          ./hosts/macbook/default.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "before-nix";
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
          }
        ];
      };

      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.aagl.nixosModules.default
            ./hosts/desktop/default.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "before-nix";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
              home-manager.users.geolan = import ./profiles/linux-desktop.nix;
            }
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            inputs.aagl.nixosModules.default
            ./hosts/laptop/default.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "before-nix";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
              home-manager.users.geolan = import ./profiles/linux-desktop.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        "mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = specialArgs;
          modules = [
            inputs.nixvim.homeModules.nixvim
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
          extraSpecialArgs = specialArgs;
          modules = [
            inputs.nixvim.homeModules.nixvim
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
