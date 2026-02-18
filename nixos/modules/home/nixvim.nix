{ inputs, pkgs, lib, config, ... }:

let
  cfg = config.mymod.home.nixvim;
  cplusPath = if pkgs.stdenv.isLinux then
    pkgs.lib.makeSearchPathOutput "dev" "include/c++" [ pkgs.gcc-unwrapped ]
  else "";
in
{
  options.mymod.home.nixvim = {
    enable = lib.mkEnableOption "nixvim configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
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

      extraPython3Packages = ps: with ps; [
        pynvim
        jupyter-client
        ipykernel
        nbformat
      ];

      plugins = {
        quarto = {
          enable = true;
          settings = {
            lspFeatures = {
              enabled = true;
              languages = [ "python" "bash" "lua" ];
              chunks = "all";
            };
            codeRunner = {
              enabled = true;
              default_method = "molten";
            };
          };
        };

        molten = {
          enable = true;
          settings = {
            auto_open_output = false;
            save_last_position = true;
            auto_export_output = true;
            image_provider = "image.nvim";
            wrap_output = true;
            virt_text_output = true;
            virt_lines_off_by_1 = true;
          };
        };

        otter.enable = true;

        image = {
          enable = true;
          backend = "ueberzug";
          maxHeightWindowPercentage = 50;
        };

        web-devicons.enable = true;
        lualine.enable = true;
        which-key.enable = true;

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

        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
          nixGrammars = true;
          nixvimInjections = true;
        };

        ts-autotag.enable = true;

        grug-far.enable = true;

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

        lsp = {
          enable = true;

          keymaps = {
            silent = true;
            diagnostic = {
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
            lua_ls.enable = true;
            nil_ls.enable = true;
            pyright.enable = true;
            gopls.enable = true;
            ts_ls.enable = true;
            html.enable = true;
            cssls.enable = true;
            tailwindcss.enable = true;
            jsonls.enable = true;
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
            cmake.enable = true;
            dockerls.enable = true;
            marksman.enable = true;
            sqls.enable = true;
            taplo.enable = true;
            yamlls.enable = true;
            texlab.enable = true;
            jdtls.enable = true;
            prismals = {
              enable = true;
              package = null;
            };
          };
        };

        conform-nvim = {
          enable = true;
          settings = {
            log_level = "warn";
            formatters_by_ft = {
              lua = [ "stylua" ];
              nix = [ "nixfmt" ];
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
              python = [ "isort" "black" ];
              go = [ "gofmt" ];
              rust = [ "rustfmt" ];
              zig = [ "zigfmt" ];
              prisma = [ "prettier" ];
              c = [ "clang-format" ];
              cpp = [ "clang-format" ];
              toml = [ "taplo" ];
              cmake = [ "cmake_format" ];
              sql = [ "sql_formatter" ];
              java = [ "google-java-format" ];
              tex = [ "latexindent" ];
              sh = [ "shfmt" ];
              bash = [ "shfmt" ];
            };
            formatters.nixfmt.command = "nixfmt";
          };
        };

        lint = {
          enable = true;
          lintersByFt = { };
        };

        trouble.enable = true;
      };

      keymaps = [
        { mode = [ "n" "v" ]; key = "<Space>"; action = "<Nop>"; options.silent = true; }
        { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
        { mode = "n"; key = "<leader>qq"; action = "<cmd>qa<cr>"; options.desc = "Quit All"; }
        { mode = "n"; key = "<leader>bd"; action.__raw = "function() require('snacks').bufdelete() end"; options.desc = "Delete Buffer"; }
        { mode = "n"; key = "<leader>gg"; action.__raw = "function() require('snacks').lazygit() end"; options.desc = "Lazygit"; }
        { mode = "n"; key = "<A-j>"; action = "<cmd>m .+1<cr>=="; options.desc = "Move Down"; }
        { mode = "n"; key = "<A-k>"; action = "<cmd>m .-2<cr>=="; options.desc = "Move Up"; }
        { mode = "i"; key = "<A-j>"; action = "<esc><cmd>m .+1<cr>==gi"; options.desc = "Move Down"; }
        { mode = "i"; key = "<A-k>"; action = "<esc><cmd>m .-2<cr>==gi"; options.desc = "Move Up"; }
        { mode = "v"; key = "<A-j>"; action = ":m '>+1<cr>gv=gv"; options.desc = "Move Down"; }
        { mode = "v"; key = "<A-k>"; action = ":m '<-2<cr>gv=gv"; options.desc = "Move Up"; }
        { mode = "n"; key = "<C-h>"; action = "<C-w>h"; }
        { mode = "n"; key = "<C-j>"; action = "<C-w>j"; }
        { mode = "n"; key = "<C-k>"; action = "<C-w>k"; }
        { mode = "n"; key = "<C-l>"; action = "<C-w>l"; }
        { mode = "n"; key = "<leader><space>"; action.__raw = "function() require('snacks').picker.smart({ multi = { 'buffers', { source = 'recent', filter = { cwd = true } }, 'files' } }) end"; options.desc = "Find Files (Smart)"; }
        { mode = "n"; key = "<leader>ff"; action.__raw = "function() require('snacks').picker.files() end"; options.desc = "Find Files"; }
        { mode = "n"; key = "<leader>fg"; action.__raw = "function() require('snacks').picker.git_files() end"; options.desc = "Git Files"; }
        { mode = "n"; key = "<leader>/"; action.__raw = "function() require('snacks').picker.grep() end"; options.desc = "Grep"; }
        { mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; options.desc = "Open Parent Directory"; }
        { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Trouble)"; }
        { mode = "n"; key = "<leader>h"; action.__raw = "function() local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list()) end"; options.desc = "Harpoon Quick Menu"; }
        { mode = "n"; key = "<leader>H"; action.__raw = "function() require('harpoon'):list():add() end"; options.desc = "Harpoon File (Add)"; }
        { mode = "n"; key = "<leader>1"; action.__raw = "function() require('harpoon'):list():select(1) end"; options.desc = "Harpoon File 1"; }
        { mode = "n"; key = "<leader>2"; action.__raw = "function() require('harpoon'):list():select(2) end"; options.desc = "Harpoon File 2"; }
        { mode = "n"; key = "<leader>3"; action.__raw = "function() require('harpoon'):list():select(3) end"; options.desc = "Harpoon File 3"; }
        { mode = "n"; key = "<leader>4"; action.__raw = "function() require('harpoon'):list():select(4) end"; options.desc = "Harpoon File 4"; }
        { mode = "n"; key = "<leader>5"; action.__raw = "function() require('harpoon'):list():select(5) end"; options.desc = "Harpoon File 5"; }
        { mode = "n"; key = "<leader>6"; action.__raw = "function() require('harpoon'):list():select(5) end"; options.desc = "Harpoon File 6"; }
        { mode = [ "n" "v" ]; key = "<leader>sr"; action = "<cmd>GrugFar<CR>"; options.desc = "Search and Replace (GrugFar)"; }
        { mode = "n"; key = "<leader>mi"; action = "<cmd>MoltenInit<cr>"; options.desc = "Initialize Molten"; }
        { mode = "n"; key = "<leader>re"; action = "<cmd>MoltenEvaluateOperator<cr>"; options.desc = "Run Operator"; }
        { mode = "n"; key = "<leader>rl"; action = "<cmd>MoltenEvaluateLine<cr>"; options.desc = "Run Line"; }
        { mode = "v"; key = "<leader>rv"; action = ":<C-u>MoltenEvaluateVisual<cr>gv"; options.desc = "Run Visual Selection"; }
        { mode = "n"; key = "<leader>rh"; action = "<cmd>MoltenHideOutput<cr>"; options.desc = "Hide Output"; }
        { mode = "n"; key = "<leader>ro"; action = "<cmd>MoltenShowOutput<cr>"; options.desc = "Show Output"; }
        { mode = "n"; key = "<leader>qp"; action = "<cmd>QuartoPreview<cr>"; options.desc = "Quarto Preview"; }
        { mode = [ "n" "x" "o" ]; key = "s"; action.__raw = "function() require('flash').jump() end"; options.desc = "Flash"; }
        { mode = [ "n" "x" "o" ]; key = "S"; action.__raw = "function() require('flash').treesitter() end"; options.desc = "Flash Treesitter"; }
        { mode = "o"; key = "r"; action.__raw = "function() require('flash').remote() end"; options.desc = "Remote Flash"; }
        { mode = [ "x" "o" ]; key = "R"; action.__raw = "function() require('flash').treesitter_search() end"; options.desc = "Treesitter Search"; }
        { mode = "n"; key = "[d"; action = "vim.diagnostic.goto_prev"; options.desc = "Prev Diagnostic"; }
        { mode = "n"; key = "]d"; action = "vim.diagnostic.goto_next"; options.desc = "Next Diagnostic"; }
        { mode = "n"; key = "<leader>cd"; action = "vim.diagnostic.open_float"; options.desc = "Line Diagnostics"; }
        { mode = "n"; key = "]h"; action = "<cmd>Gitsigns next_hunk<cr>"; options.desc = "Next Hunk"; }
        { mode = "n"; key = "[h"; action = "<cmd>Gitsigns prev_hunk<cr>"; options.desc = "Prev Hunk"; }
        { mode = "n"; key = "<leader>ghp"; action = "<cmd>Gitsigns preview_hunk<cr>"; options.desc = "Preview Hunk"; }
        { mode = "n"; key = "<leader>sq"; action.__raw = "function() require('snacks').picker.resume() end"; options.desc = "Resume Last Search"; }
        { mode = "n"; key = "<leader>sw"; action.__raw = "function() require('snacks').picker.grep_word() end"; options.desc = "Search Word Under Cursor"; }
        { mode = "n"; key = "<leader>ss"; action.__raw = "function() require('snacks').picker.lsp_symbols() end"; options.desc = "LSP Symbols"; }
        { mode = "n"; key = "[p"; action = "<Plug>(YankyCycleForward)"; options.desc = "Cycle Yank Forward"; }
        { mode = "n"; key = "]p"; action = "<Plug>(YankyCycleBackward)"; options.desc = "Cycle Yank Backward"; }
      ];

      extraPackages = with pkgs; [
        ripgrep
        fd
        gcc
        clang
        clang-tools
        nixfmt
        stylua
        nodePackages.prettier
        black
        isort
        shfmt
        cmake-format
        sql-formatter
        google-java-format
        zig
        jdt-language-server
        gopls
        gotools
        taplo
        vscode-langservers-extracted
        yaml-language-server
        texliveSmall
        quarto
        python311Packages.ipykernel
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

        ${if pkgs.stdenv.isLinux then ''
          local cpp_base = "${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}"
          local cpp_arch = "${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}/${pkgs.stdenv.hostPlatform.config}"
          vim.env.CPLUS_INCLUDE_PATH = cpp_base .. ":" .. cpp_arch
        '' else ""}

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
