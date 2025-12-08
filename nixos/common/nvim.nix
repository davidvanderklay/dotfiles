{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # --- 1. EXTERNAL TOOLS ---
    # These are available in the system PATH for Neovim to use.
    extraPackages = with pkgs; [
      # Build
      gcc gnumake unzip

      # Search & Utils (Required for Snacks/Telescope/LSP)
      ripgrep fd curl git

      # LSPs
      lua-language-server
      nil                     # Nix
      pyright                 # Python
      gopls                   # Go
      rust-analyzer           # Rust
      clang-tools             # C/C++
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
      snacks-nvim         # The new LazyVim standard (Picker, Dashboard, Utils)
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
      harpoon             # File marking
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
      # Replaces nvim-cmp, cmp-*, and luasnip
      blink-cmp
      friendly-snippets   # Snippets collection (Blink uses this)

      # -- SPECIFIC TOOLS --
      vimtex
      render-markdown-nvim
      obsidian-nvim
    ];

    # --- 3. LUA CONFIGURATION ---
    extraLuaConfig = ''
      -- ==========================================
      -- 1. GLOBALS & OPTIONS
      -- ==========================================
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
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.inccommand = "split"
      vim.opt.cursorline = true
      vim.opt.scrolloff = 10

      -- Neovim 0.11+ / Native features
      if vim.fn.has("nvim-0.10") == 1 then
        vim.opt.smoothscroll = true
      end

      -- ==========================================
      -- 2. BLINK CMP SETUP (Replaces nvim-cmp)
      -- ==========================================
      -- See: https://cmp.saghen.dev/configuration/
      require('blink.cmp').setup({
        -- Keymap preset 'default' uses:
        -- <C-space> to open menu
        -- <CR> to accept
        -- <Tab> / <S-Tab> to select next/prev
        keymap = { preset = 'default' },

        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono',
        },

        -- Sources configuration
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        
        -- Signature help (built-in to blink)
        signature = { enabled = true },
      })

      -- ==========================================
      -- 3. SNACKS.NVIM (LazyVim Core)
      -- ==========================================
      -- Provides: Dashboard, Picker (Telescope replacer), Notifications, etc.
      local snacks = require("snacks")
      snacks.setup({
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        picker = { enabled = true }, -- The Telescope alternative
      })

      -- ==========================================
      -- 4. KEYMAPS (LazyVim Style)
      -- ==========================================
      local map = vim.keymap.set

      -- General
      map("n", "<Esc>", "<cmd>nohlsearch<CR>")
      map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save File" })
      map("n", "<leader>bd", function() snacks.bufdelete() end, { desc = "Delete Buffer" })
      map("n", "<leader>bo", function() snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
      map("n", "<leader>gg", function() snacks.lazygit() end, { desc = "Lazygit" })

      -- Window Movement
      map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
      map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
      map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
      map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

      -- File Navigation (Using Snacks Picker instead of Telescope)
      map("n", "<leader><space>", function() snacks.picker.smart() end, { desc = "Find Files (Root Dir)" })
      map("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Find Files (Root Dir)" })
      map("n", "<leader>fg", function() snacks.picker.git_files() end, { desc = "Find Files (git-files)" })
      map("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "Recent" })
      map("n", "<leader>/", function() snacks.picker.grep() end, { desc = "Grep (Root Dir)" })
      map("n", "<leader>:", function() snacks.picker.command_history() end, { desc = "Command History" })
      map("n", "<leader>,", function() snacks.picker.buffers() end, { desc = "Buffers" })

      -- Oil (File Explorer)
      map("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })

      -- Diagnostics / Trouble
      map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })

      -- ==========================================
      -- 5. PLUGIN CONFIGS
      -- ==========================================

      -- Theme
      require('kanagawa').setup()
      vim.cmd("colorscheme kanagawa")

      -- Treesitter
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      })

      -- Mini
      require('mini.ai').setup()
      require('mini.pairs').setup()

      -- Yanky
      require("yanky").setup()
      map({"n","x"}, "p", "<Plug>(YankyPutAfter)")
      map({"n","x"}, "P", "<Plug>(YankyPutBefore)")
      map({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
      map({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")

      -- WhichKey
      require("which-key").setup({
        preset = "helix",
      })

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
          sh = { "shfmt" },
        },
      })

      -- ==========================================
      -- 6. LSP SETUP (Native + Blink)
      -- ==========================================
      local lspconfig = require('lspconfig')
      
      -- Get capabilities from Blink
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        lua_ls = { settings = { Lua = { diagnostics = { globals = {'vim'} } } } },
        nil_ls = {},     -- Nix
        pyright = {},    -- Python
        gopls = {},      -- Go
        clangd = {},     -- C/C++
        rust_analyzer = {}, -- Rust
        ts_ls = {},      -- TypeScript
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- LSP Keymaps (Native 0.11 style + standard)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local function map_lsp(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map_lsp('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition') -- Fallback to telescope/snacks picker if desired, or use vim.lsp.buf.definition
          map_lsp('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map_lsp('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map_lsp('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map_lsp('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map_lsp('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map_lsp('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map_lsp('K', vim.lsp.buf.hover, 'Hover Documentation')
        end,
      })

      -- ==========================================
      -- 7. OBSIDIAN (Your Provided Config)
      -- ==========================================
      require("obsidian").setup({
        workspaces = {
          { name = "personal", path = vim.fn.expand("~/notes/personal") },
          { name = "csce625", path = vim.fn.expand("~/notes/csce625") },
          { name = "csce631", path = vim.fn.expand("~/notes/csce631") },
          { name = "csce636", path = vim.fn.expand("~/notes/csce636") },
          { name = "csce765", path = vim.fn.expand("~/notes/csce765") },
        },
        daily_notes = {
          folder = "dailies",
          date_format = "%Y-%m-%d",
        },
        -- Blink/CMP integration handled automatically by blink source 'buffer'/'path' usually,
        -- but we leave this true as requested.
        completion = {
          nvim_cmp = true, 
          min_chars = 2,
        },
        templates = {
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
        },
        attachments = {
          img_folder = "assets/imgs",
          img_text_func = function(path)
            local name = vim.fs.basename(tostring(path))
            local encoded_name = require("obsidian.util").urlencode(name)
            local relative_path = "assets/imgs/" .. encoded_name
            return string.format("![%s](%s)", name, relative_path)
          end,
        },
        callbacks = {
          enter_note = function(_, note)
            vim.keymap.set("n", "<CR>", function() require("obsidian.api").smart_action() end, { buffer = note.bufnr, desc = "Smart action" })
            vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", { buffer = note.bufnr, desc = "Toggle checkbox" })
            vim.keymap.set("n", "]o", function() require("obsidian.api").nav_link("next") end, { buffer = note.bufnr, desc = "Next link" })
            vim.keymap.set("n", "[o", function() require("obsidian.api").nav_link("prev") end, { buffer = note.bufnr, desc = "Prev link" })
          end,
        },
      })

      -- Obsidian Global Keymaps
      local omap = function(mode, lhs, rhs, desc)
         vim.keymap.set(mode, lhs, rhs, { desc = desc })
      end
      omap("n", "<leader>on", "<cmd>Obsidian new<cr>", "[O]bsidian [N]ew note")
      omap("n", "<leader>os", "<cmd>Obsidian search<cr>", "[O]bsidian [S]earch")
      omap("n", "<leader>of", "<cmd>Obsidian quick_switch<cr>", "[O]bsidian [F]ind file")
      omap("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "[O]bsidian [B]acklinks")
      omap("n", "<leader>ot", "<cmd>Obsidian tags<cr>", "[O]bsidian [T]ags")
      omap("n", "<leader>oy", "<cmd>Obsidian today<cr>", "[O]bsidian toda[y]")
    '';
  };
}
