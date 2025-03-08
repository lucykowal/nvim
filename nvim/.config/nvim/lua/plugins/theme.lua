-- theme config

local function darken(color, factor)
  factor = factor or 0.95
  return require("catppuccin.utils.colors").darken(require("catppuccin.palettes.latte")[color], factor, "#000000")
end

local function get_colors()
  return {
    base = darken("base"),
    crust = darken("crust"),
    mantle = darken("mantle"),
    surface0 = darken("surface0"),
    surface1 = darken("surface1"),
    surface2 = darken("surface2"),
  }
end

vim.api.nvim_create_user_command("ColorCompile", function()
  vim.fn.setreg("l", vim.inspect(get_colors()))
end, {})

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 999,
  config = function()
    require("catppuccin").setup({
      flavour = "latte",
      color_overrides = {
        latte = {
          base = "#E3E5E9",
          crust = "#D1D5DC",
          mantle = "#DBDDE3",
          surface0 = "#C2C6CF",
          surface1 = "#B3B6C2",
          surface2 = "#A3A7B5",
        },
      },
      custom_highlights = function(colors)
        local sep = {
          fg = colors.surface2,
          bg = colors.base,
          style = { "bold" },
        }
        return {
          NormalFloat = {
            bg = colors.base,
          },
          FloatBorder = sep,
          FloatTitle = sep,
          WinSeparator = sep,

          SnacksInputNormal = { link = "NormalFloat" },
          SnacksInputBorder = { link = "FloatBorder" },
          SnacksInputTitle = { link = "FloatTitle" },
          SnacksInputIcon = sep,

          StatusLine = vim.tbl_deep_extend("force", sep, {
            style = { "underline" },
          }),
          StatusLineNC = sep,
          MiniStatuslineFilename = {
            bg = colors.base,
            fg = colors.surface2,
            style = { "bold", "underline" },
          }, -- active
          MiniStatuslineInactive = {
            fg = colors.surface2,
            bg = colors.base,
            style = { "underline" },
          }, -- inactive
          MiniStatuslineFileinfo = {
            fg = colors.surface2,
            bg = colors.base,
            style = { "underline" },
          }, -- common to both
        }
      end,
      styles = {
        comments = { "italic" },
      },
      integrations = {
        cmp = true,
        treesitter = true,
        mason = true,
        telescope = { enabled = true },
        mini = { enabled = true },
        which_key = true,
        gitsigns = true,
        render_markdown = true,
        fidget = true,
        snacks = {
          enabled = true,
          indent_scope_color = "text",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
        },
      },
    })
    vim.cmd.colorscheme("catppuccin-latte")
  end,
}
