return {
  -- 1. Disable Mason completely
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  -- 2. Configure LSP to use your Nix-installed binaries
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Tell LazyVim these servers exist and should be setup
      servers = {
        -- Lua
        lua_ls = {},

        -- Nix (nil)
        nil_ls = {},

        -- Python
        pyright = {},

        -- Go
        gopls = {},

        -- Rust
        rust_analyzer = {
          -- lazyvim usually handles rust-analyzer setup automatically if the extra is enabled,
          -- but declaring it here ensures it attaches if you aren't using the rust extra.
          mason = false,
        },

        -- C/C++
        clangd = {
          mason = false,
        },

        -- TypeScript
        -- Note: If you use the LazyVim typescript extra, it might expect 'vtsls'.
        -- Since you installed 'typescript-language-server', that corresponds to 'ts_ls' (formerly tsserver).
        ts_ls = {},
      },

      -- 3. Ensure your formatters/linters (which are not LSPs) are handled
      -- Since you disabled mason, automatic linter installation via mason-null-ls won't work.
      -- Ensure you have 'conform.nvim' or 'none-ls' configured to pick up 'prettier' and 'nixpkgs-fmt' from your path.
    },
  },
}
