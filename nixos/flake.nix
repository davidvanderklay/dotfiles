{
  description = "My NixOS and Portable Home Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # SWAP BACK TO NIXVIM
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add this input
    lanzaboote = {
      url = "github:nix-community/lanzaboote"; # Check their GitHub for latest version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nixvim,
      lanzaboote,
      ...
    }@inputs:
    {

      # --- MACOS CONFIGURATION ---
      darwinConfigurations."eth0" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook/default.nix # <--- YOUR NEW FILE

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "before-nix";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
            home-manager.users.geolan = import ./common/home-core.nix;
          }
        ];
      };

      # --- 1. NIXOS SYSTEMS (Linux Desktop & Laptop) ---
      nixosConfigurations = {

        # SYSTEM 1: Desktop
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            lanzaboote.nixosModules.lanzaboote
            # Machine Specifics
            ./hosts/desktop/default.nix
            # Common Config
            ./common/configuration.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };

              # Use NixVim Module
              home-manager.sharedModules = [ nixvim.homeModules.nixvim ];

              # Use the LINUX home config (Gnome + Gaming + Tools)
              home-manager.users.geolan = import ./common/home-linux.nix;
            }
          ];
        };

        # SYSTEM 2: Laptop
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            # Machine Specifics
            ./hosts/laptop/default.nix
            # Common Config
            ./common/configuration.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };

              # Use NixVim Module
              home-manager.sharedModules = [ nixvim.homeModules.nixvim ];

              # Use the LINUX home config
              home-manager.users.geolan = import ./common/home-linux.nix;
            }
          ];
        };
      };

      # --- 2. STANDALONE HOME (MacOS / Generic Linux) ---
      # Install with: nix run .#mac
      homeConfigurations = {

        # TARGET 1: MacOS (Apple Silicon)
        # Install with: nix run .#mac
        "mac" = home-manager.lib.homeModules {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin; # MacOS Arch
          extraSpecialArgs = { inherit inputs; };
          modules = [
            nixvim.homeModules.nixvim
            ./common/home-core.nix # The "Safe" config without Linux-specific desktop stuff
            {
              home.username = "geolan";
              home.homeDirectory = "/Users/geolan";
              home.stateVersion = "25.11";
            }
          ];
        };

        # TARGET 2: Ubuntu / Generic Linux (Intel/AMD)
        # Install with: nix run .#generic
        "generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Standard Linux Arch
          extraSpecialArgs = { inherit inputs; };
          modules = [
            nixvim.homeModules.nixvim

            # Use home-core.nix (CLI tools only)
            # OR use home-linux.nix (Desktop apps) IF it doesn't contain NixOS-specific systemd/driver flags
            ./common/home-core.nix

            {
              home.username = "geolan";
              home.homeDirectory = "/home/geolan";
              home.stateVersion = "25.11";

              # On Ubuntu, you usually need to force the targets to work alongside the native distro
              targets.genericLinux.enable = true;
            }
          ];
        };
      };
    };
}
