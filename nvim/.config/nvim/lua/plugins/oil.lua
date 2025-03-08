return {
  "stevearc/oil.nvim",
  config = function()
    local oil = require("oil")
    oil.setup({
      keymaps = {
        ["q"] = { "actions.close", mode = "n" },
        ["<C-c>"] = { "actions.close", mode = "i" },
        ["?"] = { "actions.show_help", mode = "n" },
        ["<C-/>"] = { "actions.show_help", mode = "i" },
        ["<C-l>"] = { nil },
        ["<C-h>"] = { nil },
        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["="] = { "actions.refresh", mode = "n" },
      },
      confirmation = {
        border = require("settings").window.border,
      },
      progress = {
        border = require("settings").window.border,
      },
      keymaps_help = {
        border = require("settings").window.border,
      },
      ssh = {
        border = require("settings").window.border,
      },
    })

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.keymap.set("n", "<leader>fb", function()
      oil.open(vim.uv.cwd())
    end, { desc = "[F]ile [B]rowser" })
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.keymap.set("n", "<leader>-", oil.open, { desc = "[-] To parent dir" })
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
}
