{
  description = "My NixOS and Portable Home Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs: {
    
    # --- 1. NIXOS SYSTEMS (Linux Desktop & Laptop) ---
    nixosConfigurations = {
      
      # SYSTEM 1: Desktop
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          
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
            home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
            
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
            home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
            
            # Use the LINUX home config
            home-manager.users.geolan = import ./common/home-linux.nix;
          }
        ];
      };
    };

    # --- 2. STANDALONE HOME (MacOS / Generic Linux) ---
    # Install with: nix run .#mac
    homeConfigurations = {
      
      "mac" = home-manager.lib.homeManagerConfiguration {
        # Select architecture: 'aarch64-darwin' (M1/M2/M3) or 'x86_64-darwin' (Intel)
        pkgs = nixpkgs.legacyPackages.aarch64-darwin; 
        extraSpecialArgs = { inherit inputs; };
        modules = [
          nixvim.homeManagerModules.nixvim
          
          # Use the CORE home config (Safe for Mac)
          ./common/home-core.nix 

          {
            home.username = "geolan";
            home.homeDirectory = "/Users/geolan"; # macOS standard path
            home.stateVersion = "25.11";
          }
        ];
      };
    };
  };
}
