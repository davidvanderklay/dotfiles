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

      # Indentation (LazyVim Style)
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
      lualine.enable = true;
      which-key.enable = true;
      noice.enable = true;
      
      oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = true;
        };
      };

      flash.enable = true;
      harpoon = { enable = true; enableTelescope = false; };
      mini = { enable = true; modules = { ai = {}; pairs = {}; }; };
      yanky = { enable = true; enableTelescope = false; };
      todo-comments.enable = true;

      treesitter = {
        enable = true;
        settings = {
            highlight.enable = true;
            indent.enable = true;
            ensure_installed = [
              "c" "cpp" "rust" "zig" "lua" "vim" "nix" "python" "javascript" 
              "typescript" "tsx" "json" "yaml" "toml" "html" "css" "prisma" 
              "sql" "dockerfile" "markdown" "java" "go" "cmake" "bash"
            ];
        };
        nixvimInjections = true;
      };
      
      ts-autotag.enable = true;

      snacks = {
        enable = true;
        settings = {
          dashboard.enabled = false;
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
          keymap = {
            preset = "default";
            "<CR>" = [ "accept" "fallback" ];
          };
          appearance = {
            use_nvim_cmp_as_default = true;
            nerd_font_variant = "mono";
          };
          sources.default = [ "lsp" "path" "snippets" "buffer" ];
          signature.enabled = true;
        };
      };

      # --- LSP CONFIGURATION ---
      lsp = {
        enable = true;
        servers = {
          # existing
          lua_ls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          ts_ls.enable = true;
          
          # Nix
          nil_ls.enable = true; 

          # C/C++
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

          # Rust
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };

          # NEW ADDITIONS
          zls.enable = true;          # Zig
          jsonls.enable = true;       # JSON
          cmake.enable = true;        # CMake
          dockerls.enable = true;     # Docker
          jdtls.enable = true;        # Java
          marksman.enable = true;     # Markdown
          prismals.enable = true;     # Prisma
          sqls.enable = true;         # SQL
          tailwindcss.enable = true;  # Tailwind
          texlab.enable = true;       # LaTeX
          taplo.enable = true;        # TOML
          yamlls.enable = true;       # YAML
          html.enable = true;         # HTML
          cssls.enable = true;        # CSS
        };
      };

      # --- FORMATTING (CONFORM) ---
      conform-nvim = {
        enable = true;
        settings = {
            log_level = "warn";
            
            # This map tells conform which external tool to use.
            # IMPORTANT: We removed the "*" wildcard to prevent it from blocking LSP fallbacks.
            formatters_by_ft = {
                # Scripting / Config
                lua = [ "stylua" ];
                nix = [ "nixfmt" ]; # switched to nixfmt-rfc-style
                json = [ "prettier" ];
                yaml = [ "prettier" ];
                toml = [ "taplo" ];
                cmake = [ "cmake_format" ];
                
                # Web / JS
                javascript = [ "prettier" ];
                typescript = [ "prettier" ];
                typescriptreact = [ "prettier" ]; # FIX for .tsx files
                javascriptreact = [ "prettier" ];
                html = [ "prettier" ];
                css = [ "prettier" ];
                markdown = [ "prettier" ];
                graphql = [ "prettier" ];
                
                # Backend / Systems
                python = [ "isort" "black" ];
                go = [ "gofmt" ];
                rust = [ "rustfmt" ];
                zig = [ "zigfmt" ];
                
                # C++
                # Explicitly use clang-format. This is more reliable than LSP fallback.
                c = [ "clang-format" ];
                cpp = [ "clang-format" ];
                
                # Data / Other
                sql = [ "sql_formatter" ];
                java = [ "google-java-format" ];
                tex = [ "latexindent" ];
                
                # Fallback for shell scripts
                sh = [ "shfmt" ];
                bash = [ "shfmt" ];
            };
        };
      };
      
      lint.enable = true;
      trouble.enable = true;
    };

    # --- 4. KEYMAPS ---
    keymaps = [
        # General
        { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
        { mode = "n"; key = "<leader>qq"; action = "<cmd>wqa<cr>"; options.desc = "Save All & Quit"; }
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
        
        # Oil
        { mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; options.desc = "Open Parent Directory"; }

        # Trouble
        { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Trouble)"; }
        
        # Harpoon
        { mode = "n"; key = "<leader>h"; action.__raw = "function() local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list()) end"; options.desc = "Harpoon Quick Menu"; }
        { mode = "n"; key = "<leader>H"; action.__raw = "function() require('harpoon'):list():add() end"; options.desc = "Harpoon File (Add)"; }
    ];

    # --- 5. EXTRA PACKAGES (Environment) ---
    extraPackages = with pkgs; [
      # Base Tools
      ripgrep fd gcc clang clang-tools
      
      # Formatters & Linters
      nixfmt-rfc-style  # The new standard for Nix
      stylua
      nodePackages.prettier
      black isort
      shfmt
      cmake-format
      sql-formatter
      google-java-format
      
      # Language Servers / Compilers (if not auto-installed by nixvim modules)
      zig zls
      jdt-language-server
      gopls gotools
      taplo
      vscode-langservers-extracted # html, css, json, eslint
      yaml-language-server
      texliveSmall
    ];

    # --- 6. CONFIG LUA (The Ctrl+S Fix) ---
    # We load this last to ensure the Keymap takes precedence and formats correctly.
    extraConfigLua = ''
      -- C++ Include Path setup
      vim.env.CPLUS_INCLUDE_PATH = "${pkgs.lib.makeSearchPathOutput "dev" "include/c++" [ pkgs.gcc ]}"
      
      -- Manual Format & Save Keymap
      vim.keymap.set({ "n", "i", "x" }, "<C-s>", function()
        require("conform").format({
          lsp_fallback = true,
          timeout_ms = 3000, -- 3 seconds should be plenty
          async = false,
        }, function()
          vim.cmd("write")
          print("Formatted & Saved")
        end)
      end, { desc = "Format and Save" })
    '';
  };
}
