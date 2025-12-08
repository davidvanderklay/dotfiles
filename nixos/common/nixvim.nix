{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    
    # --- 1. GENERAL SETTINGS ---
    viAlias = true;
    vimAlias = true;
    
    opts = {
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
    };

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
    };

    # --- 2. THEME ---
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

    clipboard.providers.wl-copy.enable = true;

    # --- 3. PLUGINS ---
    plugins = {
      web-devicons.enable = true;
      
      lualine = {
        enable = true;
        settings.options.theme = "kanagawa";
      };

      which-key.enable = true;
      
      noice = {
        enable = true;
        settings.notify.enabled = true;
      };

      oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = true;
        };
      };

      flash.enable = true;
      
      # --- FIX: REMOVED KEYMAPS FROM HERE ---
      harpoon = {
        enable = true;
        enableTelescope = false;
        saveOnToggle = true;
        saveOnChange = true;
      };

      mini = {
        enable = true;
        modules = {
            ai = {};
            pairs = {};
        };
      };

      yanky = {
        enable = true;
        enableTelescope = false;
      };

      todo-comments.enable = true;

      treesitter = {
        enable = true;
        settings = {
            highlight.enable = true;
            indent.enable = true;
        };
        nixvimInjections = true;
      };
      
      ts-autotag.enable = true;

      snacks = {
        enable = true;
        settings = {
          dashboard.enabled = true;
          picker.enabled = true;
          notifier.enabled = true;
          quickfile.enabled = true;
          statuscolumn.enabled = true;
          words.enabled = true;
          lazygit.enabled = true;
        };
      };

      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "default";
          appearance = {
            use_nvim_cmp_as_default = true;
            nerd_font_variant = "mono";
          };
          sources.default = [ "lsp" "path" "snippets" "buffer" ];
          signature.enabled = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          lua_ls.enable = true;
          nil_ls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          ts_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          clangd = {
            enable = true;
            cmd = [
                "clangd"
                "--background-index"
                "--clang-tidy"
                "--header-insertion=iwyu"
                "--completion-style=detailed"
            ];
          };
        };
        keymaps = {
          diagnostic = {
            "<leader>cd" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
          lspBuf = {
            "gd" = "definition";
            "gr" = "references";
            "gI" = "implementation";
            "<leader>D" = "type_definition";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
            "K" = "hover";
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
            format_on_save = {
                timeout_ms = 500;
                lsp_fallback = true;
            };
            formatters_by_ft = {
                lua = [ "nixpkgs_fmt" ];
                nix = [ "nixpkgs_fmt" ];
                javascript = [ "prettier" ];
                typescript = [ "prettier" ];
                python = [ "isort" "black" ];
                "*" = [ "trim_whitespace" ];
            };
        };
      };
      
      lint.enable = true;
      trouble.enable = true;
    };

    # --- 4. KEYMAPS (Including Harpoon Fixes) ---
    keymaps = [
        # General
        { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
        { mode = "n"; key = "<leader>qq"; action = "<cmd>qa<cr>"; options.desc = "Quit All"; }
        { mode = ["n" "i" "x"]; key = "<C-s>"; action = "<cmd>w<cr><esc>"; options.desc = "Save File"; }
        { mode = "n"; key = "<leader>bd"; action.__raw = "function() require('snacks').bufdelete() end"; options.desc = "Delete Buffer"; }
        { mode = "n"; key = "<leader>gg"; action.__raw = "function() require('snacks').lazygit() end"; options.desc = "Lazygit"; }

        # Window Nav
        { mode = "n"; key = "<C-h>"; action = "<C-w>h"; }
        { mode = "n"; key = "<C-j>"; action = "<C-w>j"; }
        { mode = "n"; key = "<C-k>"; action = "<C-w>k"; }
        { mode = "n"; key = "<C-l>"; action = "<C-w>l"; }

        # Snacks Picker
        { mode = "n"; key = "<leader><space>"; action.__raw = "function() require('snacks').picker.smart() end"; options.desc = "Find Files (Smart)"; }
        { mode = "n"; key = "<leader>ff"; action.__raw = "function() require('snacks').picker.files() end"; options.desc = "Find Files"; }
        { mode = "n"; key = "<leader>fg"; action.__raw = "function() require('snacks').picker.git_files() end"; options.desc = "Git Files"; }
        { mode = "n"; key = "<leader>/"; action.__raw = "function() require('snacks').picker.grep() end"; options.desc = "Grep"; }
        { mode = "n"; key = "<leader>:"; action.__raw = "function() require('snacks').picker.command_history() end"; options.desc = "Command History"; }
        { mode = "n"; key = "<leader>,"; action.__raw = "function() require('snacks').picker.buffers() end"; options.desc = "Buffers"; }

        # Oil
        { mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; options.desc = "Open Parent Directory"; }

        # Trouble
        { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Trouble)"; }
        
        # Yanky
        { mode = ["n" "x"]; key = "p"; action = "<Plug>(YankyPutAfter)"; }
        { mode = ["n" "x"]; key = "P"; action = "<Plug>(YankyPutBefore)"; }
        { mode = ["n" "x"]; key = "gp"; action = "<Plug>(YankyGPutAfter)"; }
        { mode = ["n" "x"]; key = "gP"; action = "<Plug>(YankyGPutBefore)"; }

        # --- FIX: HARPOON KEYMAPS MOVED HERE ---
        {
          mode = "n";
          key = "<leader>H";
          # The __raw action injects raw Lua code
          action.__raw = "function() require('harpoon'):list():add() end";
          options.desc = "Harpoon File (Add)";
        }
        {
          mode = "n";
          key = "<leader>h";
          action.__raw = "function() local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list()) end";
          options.desc = "Harpoon Quick Menu";
        }
        {
          mode = "n";
          key = "<leader>1";
          action.__raw = "function() require('harpoon'):list():select(1) end";
          options.desc = "Harpoon File 1";
        }
        {
          mode = "n";
          key = "<leader>2";
          action.__raw = "function() require('harpoon'):list():select(2) end";
          options.desc = "Harpoon File 2";
        }
        {
          mode = "n";
          key = "<leader>3";
          action.__raw = "function() require('harpoon'):list():select(3) end";
          options.desc = "Harpoon File 3";
        }
        {
          mode = "n";
          key = "<leader>4";
          action.__raw = "function() require('harpoon'):list():select(4) end";
          options.desc = "Harpoon File 4";
        }
    ];

    extraPackages = with pkgs; [
      ripgrep
      fd
      nixpkgs-fmt
      nodePackages.prettier
      shfmt
      black
      isort
    ];
  };
}
