{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # --- 1. EXTERNAL TOOLS ---
    extraPackages = with pkgs; [
      # Build tools
      gcc gnumake unzip

      # Search & Utils
      ripgrep fd curl git

      rustc
      cargo
      nodejs_22

      # LSPs
      lua-language-server
      nil                     # Nix
      pyright                 # Python
      gopls                   # Go
      rust-analyzer           # Rust
      clang-tools
      nodePackages.typescript-language-server # TS

      # Formatters
      nixpkgs-fmt
      nodePackages.prettier
      shfmt
    ];

    # --- 2. PLUGINS ---
    plugins = with pkgs.vimPlugins; [
      # -- CORE & UI --
      lazydev-nvim        # Fixes Lua LS for Neovim config
      snacks-nvim         # Dashboard, Picker, Utils (LazyVim core)
      noice-nvim          # Cmdline/Notification UI
      nui-nvim            # Dependency
      lualine-nvim        # Status line
      kanagawa-nvim       # Theme
      which-key-nvim      # Keybind helper
      nvim-web-devicons   # Icons
      todo-comments-nvim  # Highlight TODOs

      # -- NAVIGATION --
      oil-nvim            # File explorer (Buffer based)
      flash-nvim          # Fast navigation
      harpoon2             # File marking
      plenary-nvim        # Lua Utility lib

      # -- EDITING --
      mini-ai             # Better text objects
      mini-pairs          # Auto pairs
      yanky-nvim          # Clipboard history

      # -- TREESITTER --
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-ts-autotag

      # -- LSP & LINTING --
      nvim-lspconfig      # Native LSP Config
      nvim-lint           # Linters
      conform-nvim        # Formatters
      trouble-nvim        # Diagnostics list

      # -- DEBUGGING --
      nvim-dap
      nvim-dap-go
      nvim-dap-python

      # -- COMPLETION (Blink) --
      blink-cmp
      friendly-snippets   # Snippets collection
      
      # -- SPECIFIC TOOLS --
      vimtex
      render-markdown-nvim
    ];

    # --- 3. LUA CONFIGURATION ---
    extraLuaConfig = ''
      -- ==========================================
      -- 1. PRE-PLUGIN SETUP (Important for Oil)
      -- ==========================================
      -- Disable Netrw so Oil can take over directory editing
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- UI Options
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.clipboard = "unnamedplus"
      vim.opt.breakindent = true
      vim.opt.undofile = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      vim.opt.termguicolors = true
      
      -- Neovim 0.11+ Smooth Scroll
      if vim.fn.has("nvim-0.10") == 1 then
        vim.opt.smoothscroll = true
      end

      -- ==========================================
      -- 2. THEME (Kanagawa Dragon)
      -- ==========================================
      require('kanagawa').setup({
        theme = "dragon", -- Explicitly set dragon theme
        background = {
            dark = "dragon",
            light = "lotus"
        },
      })
      vim.cmd("colorscheme kanagawa-dragon")

      -- ==========================================
      -- 3. BLINK CMP SETUP
      -- ==========================================
      require('blink.cmp').setup({
        keymap = { preset = 'default' ,
        ['<CR>'] = { 'accept', 'fallback' }, 
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono',
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        signature = { enabled = true },
      })

      -- ==========================================
      -- 4. SNACKS.NVIM (Dashboard & Picker)
      -- ==========================================
      local snacks = require("snacks")
      snacks.setup({
        dashboard = { enabled = true },
        picker = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
      })

      -- ==========================================
      -- 5. KEYMAPS
      -- ==========================================

      -- ==========================================
      -- HARPOON CONFIG (LazyVim Style)
      -- ==========================================

      local map = vim.keymap.set

      local harpoon = require("harpoon")
      harpoon:setup()

      -- Keymaps
      -- <leader>H: Add current file to Harpoon
      map("n", "<leader>H", function() harpoon:list():append() end, { desc = "Harpoon File (Add)" })
      
      -- <leader>h: Toggle the Harpoon quick menu
      map("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Quick Menu" })

      -- Navigation 1-4
      map("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon to File 1" })
      map("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon to File 2" })
      map("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon to File 3" })
      map("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon to File 4" })
      map("n", "<leader>5", function() harpoon:list():select(4) end, { desc = "Harpoon to File 5" })
      map("n", "<leader>6", function() harpoon:list():select(4) end, { desc = "Harpoon to File 6" })
      map("n", "<leader>7", function() harpoon:list():select(4) end, { desc = "Harpoon to File 7" })
      map("n", "<leader>8", function() harpoon:list():select(4) end, { desc = "Harpoon to File 8" })
      
      -- Enable Telescope/Snacks integration (Optional but nice)
      -- map("n", "<leader>fh", function() toggle_telescope(harpoon:list()) end, { desc = "Open Harpoon Window" })

      -- General
      map("n", "<Esc>", "<cmd>nohlsearch<CR>")
      -- Quit All (<leader>qq)
      map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

      -- Save File (Ctrl+s)
      -- This works in Normal (n), Insert (i), and Visual (x) modes.
      -- NOTE: This triggers 'format_on_save' defined in your Conform setup automatically.
      map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
      map("n", "<leader>bd", function() snacks.bufdelete() end, { desc = "Delete Buffer" })
      map("n", "<leader>gg", function() snacks.lazygit() end, { desc = "Lazygit" })

      -- Window Movement
      map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
      map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
      map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
      map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

      -- Snacks Picker (Replaces Telescope)
      map("n", "<leader><space>", function() snacks.picker.smart() end, { desc = "Find Files (Root Dir)" })
      map("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Find Files (Root Dir)" })
      map("n", "<leader>fg", function() snacks.picker.git_files() end, { desc = "Find Files (git-files)" })
      map("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "Recent" })
      map("n", "<leader>/", function() snacks.picker.grep() end, { desc = "Grep (Root Dir)" })
      map("n", "<leader>:", function() snacks.picker.command_history() end, { desc = "Command History" })
      map("n", "<leader>,", function() snacks.picker.buffers() end, { desc = "Buffers" })

      -- Oil (File Explorer)
      -- Note: "-" is the standard LazyVim key for 'go to parent dir'
      map("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })

      -- Trouble
      -- Using Lua directly avoids "Not an editor command" errors
      map("n", "<leader>xx", function() require("trouble").toggle("diagnostics") end, { desc = "Diagnostics (Trouble)" })
      map("n", "<leader>xX", function() require("trouble").toggle("buffer") end, { desc = "Buffer Diagnostics (Trouble)" })
      map("n", "<leader>cs", function() require("trouble").toggle("symbols") end, { desc = "Symbols (Trouble)" })

      -- ==========================================
      -- 6. PLUGIN CONFIGS
      -- ==========================================
      
      -- Oil Setup
      require("oil").setup({
        default_file_explorer = true,
      })

      -- Trouble Setup (Must call setup explicitly)
      require("trouble").setup({})

      -- Treesitter
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      })

      -- Mini & Yanky
      require('mini.ai').setup()
      require('mini.pairs').setup()
      require("yanky").setup()
      -- Yanky mappings
      map({"n","x"}, "p", "<Plug>(YankyPutAfter)")
      map({"n","x"}, "P", "<Plug>(YankyPutBefore)")
      map({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
      map({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")

      -- WhichKey
      require("which-key").setup({ preset = "helix" })

      -- Lualine
      require('lualine').setup({
        options = { theme = 'kanagawa' }
      })

      -- Conform (Formatting)
      require("conform").setup({
        notify_on_error = false,
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
        formatters_by_ft = {
          lua = { "nixpkgs_fmt" },
          nix = { "nixpkgs_fmt" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          python = { "isort", "black" },
        },
      })

      -- ==========================================
      -- 7. LSP SETUP (Native + Blink)
      -- ==========================================
      local lspconfig = require('lspconfig')
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- --- Clangd Specific Setup (The Fix for Nix) ---
      -- We find where 'gcc' is in your path and tell clangd to ask it for headers.
      local clangd_cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      }

      table.insert(clangd_cmd, "--query-driver=/nix/store/**/*")

      local servers = {
        lua_ls = { settings = { Lua = { diagnostics = { globals = {'vim'} } } } },
        nil_ls = {},
        pyright = {},
        gopls = {},
        
        -- Rust: ensure you ran 'cargo init' in the folder
        rust_analyzer = {},
        
        -- TypeScript: ensure you ran 'npm install typescript' in the folder
        ts_ls = {},

        -- C++: Use our custom command with header detection
        clangd = {
            cmd = clangd_cmd,
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- LSP Keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local function map_lsp(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map_lsp('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map_lsp('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map_lsp('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map_lsp('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map_lsp('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map_lsp('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map_lsp('K', vim.lsp.buf.hover, 'Hover Documentation')
        end,
      })
    '';
  };
}
