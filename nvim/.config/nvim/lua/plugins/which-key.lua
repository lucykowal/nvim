vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    require("which-key").setup({
      win = {
        no_overlap = false,
        row = vim.o.lines,
        width = vim.o.columns,
        border = { "─", "─", "─", "", "", "", "", "" },
      },
    })
  end,
})

-- shows key bindings in a popup window
return {
  "folke/which-key.nvim",
  event = "UIEnter",
  opts = {
    preset = "classic",
    filter = function(mapping)
      return mapping.desc and mapping.desc ~= ""
    end,

    spec = {
      {
        "<leader>c",
        group = "[C]ode",
        mode = { "n", "x" },
        icon = require("nvim-web-devicons").get_icon("file", "txt"),
      },
      { "<leader>r", group = "[R]ename" },
      { "<leader>d", group = "[D]iagnostics" },
      { "<leader>s", group = "[S]earch" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>q", group = "[Q]uickfix" },
      { "<leader>f", group = "[F]iles" },
      { "<leader>v", group = "Love2D" },
    },
    win = { -- see `:help api-win_config`
      no_overlap = false,
      row = vim.o.lines,
      width = vim.o.columns,
      border = { "─", "─", "─", "", "", "", "", "" },
    },
    layout = {
      width = { min = 14, max = 40 },
      spacing = 2,
    },
    expand = 1,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = vim.g.have_nerd_font and {},
    },
    show_help = false,
  },
}
