{ config, pkgs, ... }:

{
	home.username = "geolan";
	home.homeDirectory = "/home/geolan";

	xdg.configFile."nvim".source = ./nvim;

	programs.git = {
		enable = true;
		userName = "davidvanderklay";
		userEmail = "davidvanderklay@gmail.com"	;
	};

  programs.lazygit = {
      enable = true;
    };

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;
		withNodeJs = true;
		withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];

		extraPackages = with pkgs; [
			gcc
			gnumake
			unzip
      tree-sitter
			
			# Search tools
			ripgrep
			fd

			# LSPS, formatters
			lua-language-server
			nil
			nixpkgs-fmt
			pyright
			gopls
			rust-analyzer
			clang-tools
			nodePackages.typescript-language-server
			nodePackages.prettier
		];
	};

	home.stateVersion = "25.11";
}
