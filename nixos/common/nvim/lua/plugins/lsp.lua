return {
  -- 1. Disable Mason completely
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  -- 2. Setup servers via lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- This ensures we don't accidentally rely on mason for any server
      servers = {
        -- LUA
        lua_ls = { mason = false },

        -- NIX
        nil_ls = { mason = false },

        -- PYTHON
        pyright = { mason = false },

        -- GO
        gopls = { mason = false },

        -- RUST
        rust_analyzer = { mason = false },

        -- C/C++
        clangd = { mason = false },

        -- TYPESCRIPT
        -- Note: 'ts_ls' is the new name for 'tsserver' in standard lspconfig.
        -- If you are on an older version, change this key to 'tsserver'.
        ts_ls = { mason = false },
      },
    },
  },
}
