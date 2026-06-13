{ config, pkgs, lib, ... }:

let
  cfg = config.mymod.home.nixvim;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      quarto = {
        enable = true;
        settings = {
          lspFeatures = {
            enabled = true;
            languages = [
              "python"
              "bash"
              "lua"
            ];
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
        settings = {
          backend = "kitty";
          max_height_window_percentage = 50;
        };
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
          zls.enable = true;
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
          marksman.enable = pkgs.stdenv.isLinux;
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
            python = [
              "isort"
              "black"
            ];
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
  };
}
