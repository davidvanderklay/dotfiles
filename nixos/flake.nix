{
	description = "My NixOS Flake Configuration";
	
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";

		};

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

	};
	outputs = { self, nixpkgs, home-manager, ...}@inputs:
{
	nixosConfigurations = {
		nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.geolan = import ./home.nix;
				}

			];

		};
	};
};
}
