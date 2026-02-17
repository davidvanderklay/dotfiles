{
  description = "Geolan's Modular Nix Config";

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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extra Features
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    nix-gaming.url = "github:fufexan/nix-gaming";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    lanzaboote.url = "github:nix-community/lanzaboote";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nixvim,
      ...
    }@inputs:
    let
      # This helper saves us from repeating the Home Manager logic for every host
      mkHomeManager =
        { system, user }:
        [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
            home-manager.users.${user} = import ./users/${user}/home.nix;
          }
        ];
    in
    {
      # --- 1. NIXOS HOSTS ---
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; }; # PASSES INPUTS TO ALL MODULES
          modules = [
            ./hosts/desktop/default.nix
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.aagl.nixosModules.default
          ]
          ++ (mkHomeManager {
            system = "x86_64-linux";
            user = "geolan";
          });
        };

        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/laptop/default.nix
          ]
          ++ (mkHomeManager {
            system = "x86_64-linux";
            user = "geolan";
          });
        };
      };

      # --- 2. MACOS (DARWIN) ---
      darwinConfigurations."eth0" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
            home-manager.users.geolan = import ./users/geolan/home.nix;
          }
        ];
      };

      # --- 3. STANDALONE HOME MANAGER (Generic Linux/Mac) ---
      homeConfigurations = {
        "generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./users/geolan/home.nix
            nixvim.homeModules.nixvim
            {
              home.username = "geolan";
              home.homeDirectory = "/home/geolan";
              home.stateVersion = "25.11";
              targets.genericLinux.enable = true;
            }
          ];
        };
      };
    };
}
