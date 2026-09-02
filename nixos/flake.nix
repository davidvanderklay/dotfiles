{
  description = "My NixOS and Portable Home Flake";

  # Mirrors mymod.nixos.core substituters so flake eval hits the same caches.
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://ezkea.cachix.org"
      "https://noctalia.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # Not used directly. Kept so aagl and lanzaboote follow a single
    # rust-overlay pin instead of pulling their own copies.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    t3code-flake = {
      url = "github:omarcresp/t3code-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-nix = {
      url = "github:dominicnunez/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with pkgsFor system; [
            nixfmt-tree
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

            (
              { pkgs, ... }:
              {
                # CachyOS kernel overlay. Binary cache comes from
                # mymod.nixos.core so laptop and desktop share it.
                nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
                boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
              }
            )

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

            # Same CachyOS v3 kernel as desktop. Duplicated until the
            # shared mkNixos helper lands (deferred refactor #4).
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
                boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
              }
            )

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
          # allowUnfree parity with the generic config: home core
          # installs unfree redistributables (e.g. unrar).
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
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
            mymod.home.agentConfig.enable = false;
          };
        };
      };
    };
}
