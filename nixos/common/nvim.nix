{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # --- 1. EXTERNAL TOOLS (LSPs, Formatters, etc) ---
    extraPackages = with pkgs; [
      # Base Build Tools
      gcc gnumake unzip
      
      # Search
      ripgrep fd

      # LSPs (Must match what you configure in Lua below)
      lua-language-server
      nil                     # Nix LSP
      pyright
      gopls
      rust-analyzer
      clang-tools             # clangd
      nodePackages.typescript-language-server
      
      # Formatters
      nixpkgs-fmt
      nodePackages.prettier
    ];

    # --- 2. PLUGINS (Installed via Nix) ---
    plugins = with pkgs.vimPlugins; [
      # -- UI & THEMES --
      kanagawa-nvim
      lualine-nvim
      noice-nvim
      nui-nvim
      which-key-nvim
      nvim-web-devicons
      
      # -- NAVIGATION --
      oil-nvim
      flash-nvim
      harpoon
      plenary-nvim
      
      # -- EDITING --
      mini-ai
      mini-pairs
      yanky-nvim
      todo-comments-nvim
      # ts-comments.nvim # (Note: Might need to fetch from GitHub if not in your channel, skipping for stability)
      
      # -- TREESITTER --
      # Nix compiles these for us. No 'TSInstall' needed.
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-ts-autotag
      
      # -- LSP & CODING --
      nvim-lspconfig
      nvim-lint
      conform-nvim       # Replacement for null-ls/mason-null-ls
      lazydev-nvim       # For editing Neovim Lua config
      trouble-nvim
      
      # -- DEBUGGING --
      nvim-dap
      nvim-dap-go
      nvim-dap-python

      # -- COMPLETION --
      # We use nvim-cmp for stability on Nix. 
      # (Blink is harder to get working on stable channels right now)
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      luasnip
      cmp_luasnip
      friendly-snippets

      # -- SPECIFIC TOOLS --
      vimtex
      render-markdown-nvim
      obsidian-nvim
    ];

    # --- 3. LUA CONFIGURATION (The "Kickstart" Glue) ---
    extraLuaConfig = ''
      -- ==========================================
      -- 1. OPTIONS & GLOBALS
      -- ==========================================
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = "a"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.breakindent = true
      vim.opt.undofile = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      
      -- ==========================================
      -- 2. KEYMAPS (General)
      -- ==========================================
      -- Clear highlights on search when pressing <Esc> in normal mode
      vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

      -- Oil.nvim Keymap (As requested)
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Opens parent directory" })

      -- ==========================================
      -- 3. PLUGIN SETUP
      -- ==========================================

      -- Treesitter (Config only, parsers are installed by Nix)
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = false, -- IMPORANT: Nix handles this
        ensure_installed = {},
      })

      -- WhichKey
      require("which-key").setup()

      -- Mini Plugins
      require('mini.ai').setup()
      require('mini.pairs').setup()

      -- Oil
      require("oil").setup()

      -- Yanky
      require("yanky").setup()

      -- ==========================================
      -- 4. LSP SETUP (Connects to extraPackages)
      -- ==========================================
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Helper to setup servers
      local function setup_server(server, config)
        config = config or {}
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- Lua
      setup_server('lua_ls', {
        settings = { Lua = { diagnostics = { globals = {'vim'} } } }
      })
      
      -- Nix
      setup_server('nil_ls')
      
      -- Python
      setup_server('pyright')
      
      -- Go
      setup_server('gopls')
      
      -- C/C++
      setup_server('clangd')
      
      -- Rust
      setup_server('rust_analyzer')
      
      -- TypeScript
      -- (Note: 'ts_ls' is new name for 'tsserver')
      setup_server('ts_ls')

      -- ==========================================
      -- 5. COMPLETION (nvim-cmp)
      -- ==========================================
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }

      -- ==========================================
      -- 6. OBSIDIAN CONFIG (Ported from your request)
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
      local map = function(mode, lhs, rhs, desc)
         vim.keymap.set(mode, lhs, rhs, { desc = desc })
      end
      
      map("n", "<leader>on", "<cmd>Obsidian new<cr>", "[O]bsidian [N]ew note")
      map("n", "<leader>os", "<cmd>Obsidian search<cr>", "[O]bsidian [S]earch")
      map("n", "<leader>of", "<cmd>Obsidian quick_switch<cr>", "[O]bsidian [F]ind file")
      map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "[O]bsidian [B]acklinks")
      map("n", "<leader>ot", "<cmd>Obsidian tags<cr>", "[O]bsidian [T]ags")
      map("n", "<leader>oy", "<cmd>Obsidian today<cr>", "[O]bsidian toda[y]")
      
    '';
  };
}
