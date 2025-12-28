{ inputs, pkgs, ... }:
let
  # 1. ROBUST HEADER PATH CALCULATION
  # We prefer 'gcc-unwrapped' or 'stdenv.cc.cc' to get the raw headers.
  # We also grab glibc headers just in case.
  cplusPath =
    if pkgs.stdenv.isLinux then
      pkgs.lib.makeSearchPathOutput "dev" "include/c++" [
        pkgs.gcc-unwrapped
      ]
    else
      "";
in
{

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # --- 1. GENERAL SETTINGS ---
    viAlias = true;
    vimAlias = true;

    opts = {
      confirm = true; # This is the magic setting. It prompts to save before exiting.
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

      # Indentation Fix (LazyVim Style)
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

    clipboard.providers.wl-copy.enable = pkgs.stdenv.isLinux;

    # --- 3. PLUGINS ---
    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      which-key.enable = true;

      # Git Integration
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };

      noice.enable = true;

      oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = false;
        };
      };

      flash.enable = true;
      harpoon = {
        enable = true;
        enableTelescope = false;
      };
      mini = {
        enable = true;
        modules = {
          ai = { };
          pairs = { };
        };
      };
      yanky = {
        enable = true;
        enableTelescope = false;
      };
      todo-comments.enable = true;

      # --- TREESITTER (Syntax Highlighting) ---
      treesitter = {
        enable = true;
        settings = {
          auto_install = false;
          highlight.enable = true;
          indent.enable = true;
          ensure_installed = [
            "c"
            "cpp"
            "rust"
            "zig"
            "lua"
            "vim"
            "nix"
            "python"
            "javascript"
            "typescript"
            "tsx"
            "json"
            "yaml"
            "toml"
            "html"
            "css"
            "prisma"
            "sql"
            "dockerfile"
            "markdown"
            "java"
            "go"
            "cmake"
            "bash"
            "git_config"
            "gitcommit"
            "gitignore"
            "diff"
          ];
        };
        nixvimInjections = true;
      };

      ts-autotag.enable = true;

      grug-far = {
        enable = true;
      };

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
            "<CR>" = [
              "accept"
              "fallback"
            ];
          };
          appearance = {
            use_nvim_cmp_as_default = true;
            nerd_font_variant = "mono";
          };
          sources.default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
          signature.enabled = true;
        };
      };

      # --- LSP CONFIGURATION (Language Support) ---
      lsp = {
        enable = true;

        # This is the missing part:
        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "declaration";
            gr = "references";
            gI = "implementation";
            gy = "type_definition";
            K = "hover";
            "<leader>cr" = "rename";
            "<leader>ca" = "code_action";
            "<leader>cf" = "format";
          };
        };

        servers = {
          # -- 1. Core Languages --
          lua_ls.enable = true;
          nil_ls.enable = true; # Nix
          pyright.enable = true; # Python
          gopls.enable = true; # Go

          # -- 2. Web Development --
          ts_ls.enable = true; # TypeScript / JS
          html.enable = true;
          cssls.enable = true;
          tailwindcss.enable = true;
          jsonls.enable = true;

          # -- 3. Systems --
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          zls.enable = true; # Zig

          # C/C++ Setup
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

          # -- 4. Tools & Data --
          cmake.enable = true;
          dockerls.enable = true;
          marksman.enable = true; # Markdown
          sqls.enable = true; # SQL
          taplo.enable = true; # TOML
          yamlls.enable = true; # YAML
          texlab.enable = true; # LaTeX
          jdtls.enable = true; # Java

          # -- 5. Prisma Fix --
          prismals = {
            enable = true;
            package = null;
          };
        };
      };

      # --- FORMATTING (CONFORM) ---
      conform-nvim = {
        enable = true;
        settings = {
          log_level = "warn";

          formatters_by_ft = {
            # Scripting
            lua = [ "stylua" ];
            nix = [ "nixfmt" ]; # nixfmt-rfc-style

            # Web / JS
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            typescriptreact = [ "prettier" ];
            javascriptreact = [ "prettier" ];
            html = [ "prettier" ];
            css = [ "prettier" ];
            markdown = [ "prettier" ];
            graphql = [ "prettier" ];
            json = [ "prettier" ];
            yaml = [ "prettier" ];

            # Backend
            python = [
              "isort"
              "black"
            ];
            go = [ "gofmt" ];
            rust = [ "rustfmt" ];
            zig = [ "zigfmt" ];
            prisma = [ "prettier" ]; # Prettier handles prisma files standardly

            # C/C++ (Explicitly use clang-format)
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];

            # Data / Config
            toml = [ "taplo" ];
            cmake = [ "cmake_format" ];
            sql = [ "sql_formatter" ];
            java = [ "google-java-format" ];
            tex = [ "latexindent" ];

            # Shell
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];
          };

          # Formatter configurations
          formatters = {
            nixfmt = {
              command = "nixfmt";
            };
          };
        };
      };

      lint.enable = true;
      trouble.enable = true;
    };

    # --- 4. KEYMAPS ---
    keymaps = [
      # General
      {
        mode = [
          "n"
          "v"
        ];
        key = "<Space>";
        action = "<Nop>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }
      # --- UPDATED QUIT KEYMAP ---
      {
        mode = "n";
        key = "<leader>qq";
        # Changed from "wqa" to "qa".
        # Combined with 'opts.confirm = true', this triggers the interactive prompt.
        action = "<cmd>qa<cr>";
        options.desc = "Quit All";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action.__raw = "function() require('snacks').bufdelete() end";
        options.desc = "Delete Buffer";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action.__raw = "function() require('snacks').lazygit() end";
        options.desc = "Lazygit";
      }

      {
        mode = "n";
        key = "<A-j>";
        action = "<cmd>m .+1<cr>==";
        options.desc = "Move Down";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<cmd>m .-2<cr>==";
        options.desc = "Move Up";
      }
      {
        mode = "i";
        key = "<A-j>";
        action = "<esc><cmd>m .+1<cr>==gi";
        options.desc = "Move Down";
      }
      {
        mode = "i";
        key = "<A-k>";
        action = "<esc><cmd>m .-2<cr>==gi";
        options.desc = "Move Up";
      }
      {
        mode = "v";
        key = "<A-j>";
        action = ":m '>+1<cr>gv=gv";
        options.desc = "Move Down";
      }
      {
        mode = "v";
        key = "<A-k>";
        action = ":m '<-2<cr>gv=gv";
        options.desc = "Move Up";
      }

      # Window Nav
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }

      # Snacks Picker
      {
        mode = "n";
        key = "<leader><space>";
        # We explicitly configure the 'multi' sources to restrict 'recent' to the current directory
        action.__raw = "function() require('snacks').picker.smart({ multi = { 'buffers', { source = 'recent', filter = { cwd = true } }, 'files' } }) end";
        options.desc = "Find Files (Smart)";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action.__raw = "function() require('snacks').picker.files() end";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action.__raw = "function() require('snacks').picker.git_files() end";
        options.desc = "Git Files";
      }
      {
        mode = "n";
        key = "<leader>/";
        action.__raw = "function() require('snacks').picker.grep() end";
        options.desc = "Grep";
      }

      # Oil
      {
        mode = "n";
        key = "-";
        action = "<CMD>Oil<CR>";
        options.desc = "Open Parent Directory";
      }

      # Trouble
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics (Trouble)";
      }

      # Harpoon
      {
        mode = "n";
        key = "<leader>h";
        action.__raw = "function() local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list()) end";
        options.desc = "Harpoon Quick Menu";
      }
      {
        mode = "n";
        key = "<leader>H";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Harpoon File (Add)";
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
      {
        mode = "n";
        key = "<leader>5";
        action.__raw = "function() require('harpoon'):list():select(5) end";
        options.desc = "Harpoon File 5";
      }
      {
        mode = "n";
        key = "<leader>6";
        action.__raw = "function() require('harpoon'):list():select(5) end";
        options.desc = "Harpoon File 6";
      }
      # ADD THIS: Search and Replace (Grug Far)
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>sr";
        action = "<cmd>GrugFar<CR>";
        options.desc = "Search and Replace (GrugFar)";
      }

    ];

    # --- 5. EXTRA PACKAGES (Environment) ---
    extraPackages = with pkgs; [
      # Base Tools
      ripgrep
      fd
      gcc
      clang
      clang-tools

      # Formatters & Linters
      nixfmt-rfc-style # The new standard for Nix
      stylua
      nodePackages.prettier
      black
      isort
      shfmt
      cmake-format
      sql-formatter
      google-java-format

      # Language Servers (installed manually if not by lsp module)
      zig
      zls
      jdt-language-server
      gopls
      gotools
      taplo
      vscode-langservers-extracted # html, css, json, eslint
      yaml-language-server
      texliveSmall

    ];

    # --- 6. CONFIG LUA (Ctrl+S Fix) ---
    extraConfigLua = ''
      -- C++ Include Path
        ${
          if pkgs.stdenv.isLinux then
            ''
              -- Define C++ Paths explicitly using Nix
              -- 1. Main headers (iostream, vector, etc.)
              local cpp_base = "${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}"

              -- 2. Arch-specific headers (bits/c++config.h)
              -- We look for the folder matching your system architecture
              local cpp_arch = "${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}/${pkgs.stdenv.hostPlatform.config}"

              -- Set the environment variable for Clangd
              vim.env.CPLUS_INCLUDE_PATH = cpp_base .. ":" .. cpp_arch
            ''
          else
            ""
        }

      -- Manual Format & Save Keymap
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
}
