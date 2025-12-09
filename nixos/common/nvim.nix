{ config, pkgs, lib, ... }:
let
    # Define the C++ path safely
    cplusInclude = if pkgs.stdenv.isLinux 
                   then "${pkgs.lib.makeSearchPathOutput "dev" "include/c++" [ pkgs.gcc ]}"
                   else ""; # Mac usually finds headers automatically via standard clang
in
{
  programs.nvf = {
    enable = true;
    
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;
        debugMode = {
            enable = false;
            level = 16;
            logFile = "/tmp/nvim.log";
        };

        # 1. CORE SETTINGS
        options = {
          number = true;
          relativenumber = true;
          shiftwidth = 2;
          tabstop = 2;
          softtabstop = 2;
          expandtab = true;
          smartindent = true;
          clipboard = "unnamedplus";
          timeoutlen = 300;
          termguicolors = true;
          smoothscroll = true;
        };


        # 3. LANGUAGES (LSP, Treesitter, Formatting handled automatically)
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          # Scripting / Config
          nix.enable = true;
          lua.enable = true;
          python.enable = true;
          bash.enable = true;
          markdown.enable = true;
          
          # Web
          ts.enable = true; # Typescript/Javascript
          html.enable = true;
          css.enable = true;
          sql.enable = true;
          tailwind.enable = true;

          # Systems
          rust = {
            enable = true;
            crates.enable = true;
          };
          clang.enable = true; # C/C++
          zig.enable = true;
          go.enable = true;
          java.enable = true;
        };

        # 4. AUTOCOMPLETE (Using Blink as requested)
        autocomplete = {
          blink-cmp = {
            enable = true;
            # We map your original config into 'setupOpts' 
            # so it behaves exactly like your previous setup
            setupOpts = {
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
        };
        
        # 5. UTILITY PLUGINS
        statusline.lualine.enable = true;
        telescope.enable = false; # Disabled because you use Snacks
        filetree.neo-tree.enable = false; # You prefer Oil
        git = {
            enable = true;
            gitsigns.enable = true;
        };

        # 6. CUSTOM PLUGINS (Snacks, Oil, Harpoon)
        # NVF allows raw lua config for plugins it doesn't have modules for yet
        extraPlugins = with pkgs.vimPlugins; {

          # Kanagawa Theme (Manual Setup)
          kanagawa = {
            package = kanagawa-nvim;
            setup = ''
              require('kanagawa').setup({
                theme = "dragon",
                background = {
                    dark = "dragon",
                    light = "lotus"
                }
              })
              vim.cmd("colorscheme kanagawa")
            '';
          };
          
          oil-nvim = {
            package = oil-nvim;
            setup = "require('oil').setup { default_file_explorer = true, view_options = { show_hidden = true } }";
          };

          harpoon = {
            package = harpoon2;
            setup = "require('harpoon').setup {}";
          };

          snacks-nvim = {
            package = snacks-nvim;
            setup = ''
              require('snacks').setup({
                picker = { enabled = true },
                notifier = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = true },
                lazygit = { enabled = true },
                dashboard = { enabled = false }
              })
            '';
          };
          
          trouble = {
            package = trouble-nvim;
            setup = "require('trouble').setup {}";
          };
        };

        # 7. KEYMAPS
        keymaps = [
          # General
          { key = "<Esc>"; mode = ["n"]; action = ":nohlsearch<CR>"; silent = true; }
          { key = "<leader>qq"; mode = ["n"]; action = ":wqa<CR>"; desc = "Save & Quit"; }
          { key = "<leader>bd"; mode = ["n"]; action = ":lua require('snacks').bufdelete()<CR>"; desc = "Delete Buffer"; }
          { key = "<leader>gg"; mode = ["n"]; action = ":lua require('snacks').lazygit()<CR>"; desc = "Lazygit"; }

          # Snacks Picker
          { key = "<leader><space>"; mode = ["n"]; action = ":lua require('snacks').picker.smart({ multi = { 'buffers', { source = 'recent', filter = { cwd = true } }, 'files' } })<CR>"; desc = "Find Files (Smart)"; }
          { key = "<leader>ff"; mode = ["n"]; action = ":lua require('snacks').picker.files()<CR>"; desc = "Find Files"; }
          { key = "<leader>/"; mode = ["n"]; action = ":lua require('snacks').picker.grep()<CR>"; desc = "Grep"; }

          # Oil
          { key = "-"; mode = ["n"]; action = ":Oil<CR>"; desc = "Open Parent Directory"; }

          # Harpoon
          { key = "<leader>h"; mode = ["n"]; action = ":lua local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list())<CR>"; desc = "Harpoon Menu"; }
          { key = "<leader>H"; mode = ["n"]; action = ":lua require('harpoon'):list():add()<CR>"; desc = "Harpoon Add"; }
          { key = "<leader>1"; mode = ["n"]; action = ":lua require('harpoon'):list():select(1)<CR>"; }
          { key = "<leader>2"; mode = ["n"]; action = ":lua require('harpoon'):list():select(2)<CR>"; }
          { key = "<leader>3"; mode = ["n"]; action = ":lua require('harpoon'):list():select(3)<CR>"; }
          { key = "<leader>4"; mode = ["n"]; action = ":lua require('harpoon'):list():select(4)<CR>"; }

          # Format (Manual)
          { key = "<C-s>"; mode = ["n" "i" "x"]; action = ":w<CR>"; desc = "Save"; }
        ];
        
        # 8. EXTRA LUA
        luaConfigRC.extra = ''
           -- Only set this on Linux
           if "${cplusInclude}" ~= "" then
             vim.env.CPLUS_INCLUDE_PATH = "${cplusInclude}"
           end

           vim.keymap.set({ "n", "i", "x" }, "<C-s>", function() vim.cmd("write") end)
        '';
      };
    };
  };
}
