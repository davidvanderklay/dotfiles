-- lua/plugins/obsidian.lua
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp", -- Required for completion
    -- "nvim-telescope/telescope.nvim", -- Required for search if you use telescope
  },

  opts = {
    workspaces = {
      {
        name = "personal",
        path = vim.fn.expand("~/notes/personal"),
      },
      {
        name = "csce625",
        path = vim.fn.expand("~/notes/csce625"),
      },
      {
        name = "csce631",
        path = vim.fn.expand("~/notes/csce631"),
      },
      {
        name = "csce636",
        path = vim.fn.expand("~/notes/csce636"),
      },
      {
        name = "csce765",
        path = vim.fn.expand("~/notes/csce765"),
      },
    },

    daily_notes = {
      folder = "dailies",
      date_format = "%Y-%m-%d",
    },

    completion = {
      nvim_cmp = false, -- Disabled as you prefer blink
      blink = true, -- Enabled based on your preference
      min_chars = 2,
    },

    picker = {
      name = "snacks.pick", -- Set based on your preference
    },

    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    -- In your opts = { ... } table
    attachments = {
      img_folder = "assets/imgs",

      img_text_func = function(path)
        -- This approach is adapted directly from the plugin's documentation.

        -- 1. Get just the filename (the "basename") from the full path object.
        -- The `tostring(path)` gives the full absolute path, e.g., "/Users/.../image.png"
        local name = vim.fs.basename(tostring(path))

        -- 2. URL-encode the filename to handle spaces and special characters safely.
        local encoded_name = require("obsidian.util").urlencode(name)

        -- 3. Prepend your configured image folder to create the correct relative path.
        local relative_path = "assets/imgs/" .. encoded_name

        -- 4. Create the final standard Markdown link.
        return string.format("![%s](%s)", name, relative_path)
      end,
    },

    -- This is the new, correct way to set up buffer-local keymaps.
    -- These mappings will only be active in your Obsidian notes.
    callbacks = {
      enter_note = function(_, note)
        -- Smart action on <CR>
        vim.keymap.set("n", "<CR>", function()
          require("obsidian.api").smart_action()
        end, { buffer = note.bufnr, desc = "Smart action (follow link, toggle checkbox, etc.)" })

        -- Toggle checkbox
        vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
          buffer = note.bufnr,
          desc = "Toggle checkbox",
        })

        -- Navigate to next/previous link
        vim.keymap.set("n", "]o", function()
          require("obsidian.api").nav_link("next")
        end, {
          buffer = note.bufnr,
          desc = "Go to next link",
        })
        vim.keymap.set("n", "[o", function()
          require("obsidian.api").nav_link("prev")
        end, {
          buffer = note.bufnr,
          desc = "Go to previous link",
        })
      end,
    },
  },

  -- These are global keymaps. They will work from any buffer.
  keys = {
    -- Finding and searching notes.
    { "<leader>of", "<cmd>Obsidian quick_switch<cr>", desc = "[O]bsidian [F]ind file (Quick Switch)" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "[O]bsidian [S]earch for text" },
    { "<leader>og", "<cmd>Telescope live_grep<cr>", desc = "[O]bsidian [G]rep (live) in vault" },

    -- Creating and managing notes.
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "[O]bsidian [N]ew note" },
    { "<leader>oN", "<cmd>Obsidian new_from_template<cr>", desc = "[O]bsidian [N]ew note from template" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "[O]bsidian [R]ename note" },

    -- Daily notes.
    { "<leader>oy", "<cmd>Obsidian today<cr>", desc = "[O]bsidian note for toda[y]" },
    { "<leader>oY", "<cmd>Obsidian yesterday<cr>", desc = "[O]bsidian note for [Y]esterday" },
    { "<leader>oT", "<cmd>Obsidian tomorrow<cr>", desc = "[O]bsidian note for [T]omorrow" },

    -- Links and references.
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "[O]bsidian [B]acklinks" },
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "[O]bsidian [L]ist all links in buffer" },
    { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "[O]bsidian find by [T]ag" },
    { "<leader>oo", "<cmd>Obsidian toc<cr>", desc = "[O]bsidian [O]utline / TOC for current note" },

    -- Workspace and templates.
    { "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "[O]bsidian switch [W]orkspace" },
    { "<leader>oi", "<cmd>Obsidian template<cr>", desc = "[O]bsidian [I]nsert template" },

    -- Clipboard/Image pasting.
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "[O]bsidian [P]aste image from clipboard" },

    -- Visual mode mappings.
    { "<leader>ol", "<cmd>Obsidian link<cr>", mode = "v", desc = "[O]bsidian [L]ink selection to a note" },
    {
      "<leader>oN",
      "<cmd>Obsidian link_new<cr>",
      mode = "v",
      desc = "[O]bsidian create [N]ew note from selection",
    },
    {
      "<leader>oe",
      "<cmd>Obsidian extract_note<cr>",
      mode = "v",
      desc = "[O]bsidian [E]xtract selection into new note",
    },
  },
}
