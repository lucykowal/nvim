return { -- collection of various small independent plugins/modules
  "echasnovski/mini.nvim",
  config = function()
    -- around/inside i.e.
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require("mini.ai").setup({ n_lines = 500 })

    -- add/delete/replace surroundings (brackets, quotes, etc.)
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require("mini.surround").setup()

    -- move selection or line up/down
    -- - <M-hjkl> to move, where M is Alt
    require("mini.move").setup()

    -- autopairs
    require("mini.pairs").setup()

    -- - gcc - comment line
    require("mini.comment").setup()

    -- statusline
    local function get_line(accent)
      return function()
        local git = MiniStatusline.section_git({ trunc_width = 40 })
        local filename = MiniStatusline.section_filename({ trunc_width = 100 })
        local diagnostics = MiniStatusline.section_diagnostics({ 80 })
        local location = "%l %c"

        return MiniStatusline.combine_groups({
          { hl = accent, strings = { git, filename } },
          { hl = "MiniStatuslineFileinfo", strings = { "%<", "%=", diagnostics, location } },
        })
      end
    end
    require("mini.statusline").setup({
      content = {
        active = get_line("MiniStatuslineFilename"),
        inactive = get_line("MiniStatuslineInactive"),
      },
    })
  end,
}
