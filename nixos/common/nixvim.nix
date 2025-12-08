{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    
    # --- 1. GENERAL SETTINGS ---
    viAlias = true;
    vimAlias = true;
    
    # Equivalent to vim.opt
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
      # Smooth scroll for neovim >= 0.10
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

    # --- 3. CLIPBOARD & MOUSE ---
    clipboard.providers.wl-copy.enable = true; # Assuming Wayland (Gnome), otherwise xclip

    # --- 4. PLUGINS ---
    plugins = {
      # Core / UI
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

      # Navigation
      oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = true;
        };
      };

      flash.enable = true;
      
      harpoon = {
        enable = true;
        enableTelescope = false; # Using Snacks picker instead if possible, or raw UI
        keymaps = {
            addFile = "<leader>H";
            toggleQuickMenu = "<leader>h";
            navFile = {
                "1" = "<leader>1";
                "2" = "<leader>2";
                "3" = "<leader>3";
                "4" = "<leader>4";
            };
        };
      };

      # Editing
      mini = {
        enable = true;
        modules = {
            ai = {};
            pairs = {};
        };
      };

      yanky = {
        enable = true;
        enableTelescope = false; # We use Snacks
      };

      todo-comments.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        settings = {
            highlight.enable = true;
            indent.enable = true;
        };
        nixvimInjections = true; # Better nix support
      };
      
      ts-autotag.enable = true;

      # --- SNACKS (Dashboard, Picker, Etc) ---
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

      # --- LSP & COMPLETION ---
      
      # Blink CMP (Fast completion)
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

      # LSP Configurations
      lsp = {
        enable = true;
        
        # NixVim handles the PATHs for these automatically!
        servers = {
          lua_ls.enable = true;
          nil_ls.enable = true; # Nix
          pyright.enable = true; # Python
          gopls.enable = true; # Go
          
          # TypeScript
          ts_ls.enable = true;

          # Rust
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };

          # C++
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
          # Diagnostic keymaps
          diagnostic = {
            "<leader>cd" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
          
          # Buffer keymaps (only attach when LSP is active)
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

      # Formatting
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
      
      # Linting
      lint = {
        enable = true;
        # Linters are configured per filetype here
      };

      # Diagnostics View
      trouble.enable = true;
    };

    # --- 5. KEYMAPS ---
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

        # Snacks Picker (Replacing Telescope)
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
    ];

    # --- 6. EXTRA PACKAGES ---
    # Binaries that plugins might need but NixVim doesn't strictly wrap (formatters, etc)
    extraPackages = with pkgs; [
      ripgrep
      fd
      nixpkgs-fmt
      nodePackages.prettier
      shfmt
      black
      isort
      # gcc # GCC is usually handled by system, but can be added here if clangd needs headers
    ];
  };
}
