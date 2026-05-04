{ config, pkgs, lib, ... }:

let
  cfg = config.mymod.home.nixvim;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      nixpkgs.useGlobalPackages = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      filetype = {
        extension = {
          lock = "json";
          conf = "conf";
          env = "sh";
          "env.local" = "sh";
          "env.example" = "sh";
          tm = "toml";
          tf = "hcl";
          tfvars = "hcl";
          zsh = "zsh";
          bash = "sh";
        };

        filename = {
          ".prettierrc" = "json";
          ".eslintrc" = "json";
          ".babelrc" = "json";
          ".stylelintrc" = "json";
          "Brewfile" = "ruby";
          "Jenkinsfile" = "groovy";
          "Fastfile" = "ruby";
          "ignore" = "gitignore";
        };

        pattern = {
          "\\.env\\..*" = "sh";
          "docker-compose.*\\.yml" = "yaml.docker-compose";
          "docker-compose.*\\.yaml" = "yaml.docker-compose";
        };
      };

      opts = {
        confirm = true;
        number = true;
        relativenumber = true;
        clipboard = "unnamedplus";
        breakindent = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        signcolumn = "yes";
        updatetime = 250;
        timeoutlen = 300;
        termguicolors = true;
        smoothscroll = true;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        softtabstop = 2;
        smartindent = true;
      };

      globals = {
        mapleader = " ";
        maplocalleader = "\\";
      };

      colorschemes.kanagawa = {
        enable = true;
        settings = {
          theme = "dragon";
          background = {
            dark = "dragon";
            light = "lotus";
          };
        };
      };

      extraPython3Packages =
        ps: with ps; [
          pynvim
          jupyter-client
          ipykernel
          nbformat
        ];

      extraPackages = with pkgs; [
        ripgrep
        fd
        gcc
        clang
        clang-tools
        nixfmt
        stylua
        prettier
        black
        isort
        shfmt
        cmake-format
        sql-formatter
        google-java-format
        zig
        zls
        jdt-language-server
        gopls
        gotools
        taplo
        vscode-langservers-extracted
        yaml-language-server
        texliveSmall
        quarto
        python3Packages.ipykernel
        imagemagick
      ];

      extraConfigLua = ''
        if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
          vim.g.clipboard = {
            name = 'OSC 52',
            copy = {
              ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
              ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
            },
            paste = {
              ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
              ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
            },
          }
        end

        ${
          if pkgs.stdenv.isLinux then
            ''
              local cpp_base = "${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}"
              local cpp_arch = "${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}/${pkgs.stdenv.hostPlatform.config}"
              vim.env.CPLUS_INCLUDE_PATH = cpp_base .. ":" .. cpp_arch
            ''
          else
            ""
        }

        vim.keymap.set({ "n", "i", "x" }, "<C-s>", function()
          require("conform").format({
            lsp_fallback = true,
            timeout_ms = 3000,
            async = false,
          }, function()
            vim.cmd("write")
          end)
        end, { desc = "Format and Save" })
      '';
    };
  };
}
