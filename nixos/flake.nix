{
	description = "My NixOS Flake Configuration";
	
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";

		};

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
# --- ADD THIS ---
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

	};
	outputs = { self, nixpkgs, home-manager, ...}@inputs:
{
 nixosConfigurations = {
    
    # SYSTEM 1: Your Desktop
    desktop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; } 

        # 1. Machine Specifics
        ./hosts/desktop/default.nix
        # 2. Common Config
        ./common/configuration.nix
        # 3. Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.geolan = import ./common/home.nix;
        }
      ];
    };

    # SYSTEM 2: Your Laptop (The new machine)
    laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; } 
        # 1. Machine Specifics (Different hardware config!)
        ./hosts/laptop/default.nix
        # 2. Common Config (Reused!)
        ./common/configuration.nix
        # 3. Home Manager (Reused!)
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.geolan = import ./common/home.nix;
        }
      ];
    };

  };
};
}
