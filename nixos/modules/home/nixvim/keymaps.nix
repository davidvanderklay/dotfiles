{ config, lib, ... }:

let
  cfg = config.mymod.home.nixvim;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim.keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<Space>";
        action = "<Nop>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>qa<cr>";
        options.desc = "Quit All";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action.__raw = "function() require('snacks').bufdelete() end";
        options.desc = "Delete Buffer";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action.__raw = "function() require('snacks').lazygit() end";
        options.desc = "Lazygit";
      }
      {
        mode = "n";
        key = "<A-j>";
        action = "<cmd>m .+1<cr>==";
        options.desc = "Move Down";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<cmd>m .-2<cr>==";
        options.desc = "Move Up";
      }
      {
        mode = "i";
        key = "<A-j>";
        action = "<esc><cmd>m .+1<cr>==gi";
        options.desc = "Move Down";
      }
      {
        mode = "i";
        key = "<A-k>";
        action = "<esc><cmd>m .-2<cr>==gi";
        options.desc = "Move Up";
      }
      {
        mode = "v";
        key = "<A-j>";
        action = ":m '>+1<cr>gv=gv";
        options.desc = "Move Down";
      }
      {
        mode = "v";
        key = "<A-k>";
        action = ":m '<-2<cr>gv=gv";
        options.desc = "Move Up";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }
      {
        mode = "n";
        key = "<leader><space>";
        action.__raw = "function() require('snacks').picker.smart({ multi = { 'buffers', { source = 'recent', filter = { cwd = true } }, 'files' } }) end";
        options.desc = "Find Files (Smart)";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action.__raw = "function() require('snacks').picker.files() end";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action.__raw = "function() require('snacks').picker.git_files() end";
        options.desc = "Git Files";
      }
      {
        mode = "n";
        key = "<leader>/";
        action.__raw = "function() require('snacks').picker.grep() end";
        options.desc = "Grep";
      }
      {
        mode = "n";
        key = "-";
        action = "<CMD>Oil<CR>";
        options.desc = "Open Parent Directory";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>h";
        action.__raw = "function() local harpoon = require('harpoon'); harpoon.ui:toggle_quick_menu(harpoon:list()) end";
        options.desc = "Harpoon Quick Menu";
      }
      {
        mode = "n";
        key = "<leader>H";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Harpoon File (Add)";
      }
      {
        mode = "n";
        key = "<leader>1";
        action.__raw = "function() require('harpoon'):list():select(1) end";
        options.desc = "Harpoon File 1";
      }
      {
        mode = "n";
        key = "<leader>2";
        action.__raw = "function() require('harpoon'):list():select(2) end";
        options.desc = "Harpoon File 2";
      }
      {
        mode = "n";
        key = "<leader>3";
        action.__raw = "function() require('harpoon'):list():select(3) end";
        options.desc = "Harpoon File 3";
      }
      {
        mode = "n";
        key = "<leader>4";
        action.__raw = "function() require('harpoon'):list():select(4) end";
        options.desc = "Harpoon File 4";
      }
      {
        mode = "n";
        key = "<leader>5";
        action.__raw = "function() require('harpoon'):list():select(5) end";
        options.desc = "Harpoon File 5";
      }
      {
        mode = "n";
        key = "<leader>6";
        action.__raw = "function() require('harpoon'):list():select(5) end";
        options.desc = "Harpoon File 6";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>sr";
        action = "<cmd>GrugFar<CR>";
        options.desc = "Search and Replace (GrugFar)";
      }
      {
        mode = "n";
        key = "<leader>mi";
        action = "<cmd>MoltenInit<cr>";
        options.desc = "Initialize Molten";
      }
      {
        mode = "n";
        key = "<leader>re";
        action = "<cmd>MoltenEvaluateOperator<cr>";
        options.desc = "Run Operator";
      }
      {
        mode = "n";
        key = "<leader>rl";
        action = "<cmd>MoltenEvaluateLine<cr>";
        options.desc = "Run Line";
      }
      {
        mode = "v";
        key = "<leader>rv";
        action = ":<C-u>MoltenEvaluateVisual<cr>gv";
        options.desc = "Run Visual Selection";
      }
      {
        mode = "n";
        key = "<leader>rh";
        action = "<cmd>MoltenHideOutput<cr>";
        options.desc = "Hide Output";
      }
      {
        mode = "n";
        key = "<leader>ro";
        action = "<cmd>MoltenShowOutput<cr>";
        options.desc = "Show Output";
      }
      {
        mode = "n";
        key = "<leader>qp";
        action = "<cmd>QuartoPreview<cr>";
        options.desc = "Quarto Preview";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action.__raw = "function() require('flash').jump() end";
        options.desc = "Flash";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action.__raw = "function() require('flash').treesitter() end";
        options.desc = "Flash Treesitter";
      }
      {
        mode = "o";
        key = "r";
        action.__raw = "function() require('flash').remote() end";
        options.desc = "Remote Flash";
      }
      {
        mode = [
          "x"
          "o"
        ];
        key = "R";
        action.__raw = "function() require('flash').treesitter_search() end";
        options.desc = "Treesitter Search";
      }
      {
        mode = "n";
        key = "[d";
        action = "vim.diagnostic.goto_prev";
        options.desc = "Prev Diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = "vim.diagnostic.goto_next";
        options.desc = "Next Diagnostic";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = "vim.diagnostic.open_float";
        options.desc = "Line Diagnostics";
      }
      {
        mode = "n";
        key = "]h";
        action = "<cmd>Gitsigns next_hunk<cr>";
        options.desc = "Next Hunk";
      }
      {
        mode = "n";
        key = "[h";
        action = "<cmd>Gitsigns prev_hunk<cr>";
        options.desc = "Prev Hunk";
      }
      {
        mode = "n";
        key = "<leader>ghp";
        action = "<cmd>Gitsigns preview_hunk<cr>";
        options.desc = "Preview Hunk";
      }
      {
        mode = "n";
        key = "<leader>sq";
        action.__raw = "function() require('snacks').picker.resume() end";
        options.desc = "Resume Last Search";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action.__raw = "function() require('snacks').picker.grep_word() end";
        options.desc = "Search Word Under Cursor";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action.__raw = "function() require('snacks').picker.lsp_symbols() end";
        options.desc = "LSP Symbols";
      }
      {
        mode = "n";
        key = "[p";
        action = "<Plug>(YankyCycleForward)";
        options.desc = "Cycle Yank Forward";
      }
      {
        mode = "n";
        key = "]p";
        action = "<Plug>(YankyCycleBackward)";
        options.desc = "Cycle Yank Backward";
      }
    ];
  };
}
