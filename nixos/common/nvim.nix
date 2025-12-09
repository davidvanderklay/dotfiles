{ config, pkgs, ... }:

let
    # Define the C++ path safely
    cplusInclude = if pkgs.stdenv.isLinux 
                   then "${pkgs.lib.makeSearchPathOutput "dev" "include/c++" [ pkgs.gcc ]}"
                   else ""; 
in
{
  programs.nvf = {
    enable = true;
    
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;
        
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

        # 2. UI & INTERFACE (The "Cool Stuff")
        ui = {
            # "noice" is the plugin that makes the command line fancy and centered
            noice.enable = true; 
            
            # Add borders to various windows
            borders.enable = true; 
        };

        # "which-key" is the popup that shows keybindings when you press space
        binds.whichKey.enable = true; 

        # 3. LSP & FORMATTING
        lsp = {
            enable = true;
            formatOnSave = true; 
            lightbulb.enable = true; 
            
            # FIX: This restores the standard LSP keybinds (gd, gr, K, etc.)
            lspKeymaps = true; 
        };

        # 4. LANGUAGES
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          
          # Scripting
          nix.enable = true;
          lua.enable = true;
          python.enable = true;
          bash.enable = true;
          markdown.enable = true;
          
          # Web
          ts.enable = true;
          html.enable = true;
          css.enable = true;
          sql.enable = true;
          tailwind.enable = true;

          # Systems
          rust = {
            enable = true;
            crates.enable = true;
          };
          clang.enable = true;
          zig.enable = true;
          go.enable = true;
          java.enable = true;
        };

        # 5. AUTOCOMPLETE
        autocomplete = {
          blink-cmp = {
            enable = true;
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
        
        # 6. UTILITY PLUGINS
        statusline.lualine.enable = true;
        telescope.enable = false;
        filetree.neo-tree.enable = false;
        git = {
            enable = true;
            gitsigns.enable = true;
        };

        # 7. CUSTOM PLUGINS
        extraPlugins = with pkgs.vimPlugins; {

          # Kanagawa Theme
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
                
                -- LAZYGIT INTEGRATION
                -- configure = true usually fixes the theme, but can cause crashes if it can't write config.
                -- We enable it here. If it crashes, set to false and configure theme in home-manager.
                lazygit = { 
                    enabled = true,
                    configure = true, 
                    config = {
                        gui = {
                            theme = {
                                activeBorderColor = { fg = "Label", bold = true },
                                selectedLineBgColor = { bg = "CursorLine" },
                            }
                        }
                    }
                },
                
                dashboard = { enabled = false }
              })
            '';
          };
          
          trouble = {
            package = trouble-nvim;
            setup = "require('trouble').setup {}";
          };
        };

        # 8. KEYMAPS
        keymaps = [
          # --- General ---
          { key = "<Esc>"; mode = ["n"]; action = ":nohlsearch<CR>"; silent = true; }
          { key = "<leader>qq"; mode = ["n"]; action = ":wqa<CR>"; desc = "Save & Quit"; }
          { key = "<leader>bd"; mode = ["n"]; action = ":lua require('snacks').bufdelete()<CR>"; desc = "Delete Buffer"; }
          { key = "<leader>gg"; mode = ["n"]; action = ":lua require('snacks').lazygit()<CR>"; desc = "Lazygit"; }

          # --- LazyVim Move Lines (Alt-j / Alt-k) ---
          { key = "<A-j>"; mode = ["n"]; action = ":m .+1<CR>=="; desc = "Move Down"; }
          { key = "<A-k>"; mode = ["n"]; action = ":m .-2<CR>=="; desc = "Move Up"; }
          { key = "<A-j>"; mode = ["i"]; action = "<Esc>:m .+1<CR>==gi"; desc = "Move Down"; }
          { key = "<A-k>"; mode = ["i"]; action = "<Esc>:m .-2<CR>==gi"; desc = "Move Up"; }
          { key = "<A-j>"; mode = ["v"]; action = ":m '>+1<CR>gv=gv"; desc = "Move Down"; }
          { key = "<A-k>"; mode = ["v"]; action = ":m '<-2<CR>gv=gv"; desc = "Move Up"; }

          # --- Snacks Picker ---
          { key = "<leader><space>"; mode = ["n"]; action = ":lua require('snacks').picker.smart({ multi = { 'buffers', { source = 'recent', filter = { cwd = true } }, 'files' } })<CR>"; desc = "Find Files (Smart)"; }
          { key = "<leader>ff"; mode = ["n"]; action = ":lua require('snacks').picker.files()<CR>"; desc = "Find Files"; }
          { key = "<leader>/"; mode = ["n"]; action = ":lua require('snacks').picker.grep()<CR>"; desc = "Grep"; }

          # --- Oil ---
          { key = "-"; mode = ["n"]; action = ":Oil<CR>"; desc = "Open Parent Directory"; }

          # --- Harpoon ---
          { key = "<leader>h"; mode = ["n"]; action = ":lua local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list())<CR>"; desc = "Harpoon Menu"; }
          { key = "<leader>H"; mode = ["n"]; action = ":lua require('harpoon'):list():add()<CR>"; desc = "Harpoon Add"; }
          { key = "<leader>1"; mode = ["n"]; action = ":lua require('harpoon'):list():select(1)<CR>"; }
          { key = "<leader>2"; mode = ["n"]; action = ":lua require('harpoon'):list():select(2)<CR>"; }
          { key = "<leader>3"; mode = ["n"]; action = ":lua require('harpoon'):list():select(3)<CR>"; }
          { key = "<leader>4"; mode = ["n"]; action = ":lua require('harpoon'):list():select(4)<CR>"; }

          # --- Manual Save ---
          { key = "<C-s>"; mode = ["n" "i" "x"]; action = ":w<CR>"; desc = "Save"; }
        ];
        
        # 9. EXTRA LUA (Fixes & Hacks)
        luaConfigRC.extra = ''
           -- 1. C++ Include Fix (Linux only)
           if "${cplusInclude}" ~= "" then
             vim.env.CPLUS_INCLUDE_PATH = "${cplusInclude}"
           end
           
           -- 2. Ctrl+S Save
           vim.keymap.set({ "n", "i", "x" }, "<C-s>", function() vim.cmd("write") end)

           -- 3. SILENCE DEPRECATION WARNINGS
           -- This filters out the annoying "lspconfig is deprecated" message
           local notify = vim.notify
           vim.notify = function(msg, ...)
               if msg:match("require%('lspconfig'%) framework is deprecated") then
                   return
               end
               notify(msg, ...)
           end
        '';
      };
    };
  };
}
