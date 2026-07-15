{
  description = "My NixOS and Portable Home Flake";

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://ezkea.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
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
    t3code-flake.url = "github:omarcresp/t3code-flake";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    opencode-nix.url = "github:dominicnunez/opencode-nix";
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

      homeManagerCommon = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "before-nix";
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
      };

      standaloneHome =
        {
          pkgs,
          userName,
          homeDirectory,
          extraConfig ? { },
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = specialArgs;
          modules = [
            inputs.nixvim.homeModules.nixvim
            ./modules/home
            {
              mymod.home = {
                core = {
                  enable = true;
                  inherit userName homeDirectory;
                };
                nixvim.enable = true;
              };
              home.stateVersion = "25.11";
            }
            extraConfig
          ];
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
          homeManagerCommon
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
            homeManagerCommon
            { home-manager.users.geolan = import ./profiles/linux-desktop.nix; }
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            inputs.aagl.nixosModules.default
            ./hosts/laptop/default.nix

            home-manager.nixosModules.home-manager
            homeManagerCommon
            { home-manager.users.geolan = import ./profiles/linux-desktop.nix; }
          ];
        };
      };

      homeConfigurations = {
        "mac" = standaloneHome {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          userName = "geolan";
          homeDirectory = "/Users/geolan";
        };

        "generic" = standaloneHome {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          userName = "van";
          homeDirectory = "/home/van";
          extraConfig = {
            targets.genericLinux.enable = true;
          };
        };
      };
    };
}
