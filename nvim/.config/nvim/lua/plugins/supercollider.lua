-- supercollider

return { -- supercollider
  "davidgranstrom/scnvim",
  ft = { "supercollider" },
  config = function()
    local scnvim = require("scnvim")
    local map = scnvim.map

    scnvim.setup({
      documentation = {
        cmd = "/opt/homebrew/bin/pandoc",
      },
      keymaps = {
        ["<leader>E"] = map("editor.send_line", { "i", "n" }),
        ["<leader>e"] = {
          map("editor.send_block", { "i", "n" }),
          map("editor.send_selection", { "x" }),
        },
      },
    })

    -- use telescope instead of qflist
    ---@diagnostic disable-next-line: undefined-field
    require("scnvim.help").on_select:replace(function(err, results)
      if err then
        vim.notify(err, vim.log.levels.ERROR)
      end
      vim.ui.select(results, {
        prompt = "SCDOC",
        format_item = function(i)
          return i.text
        end,
      }, function(choice)
        require("scnvim.help").on_open(nil, choice.filename, choice.text)
      end)
    end)

    -- TODO: replace on_open?

    vim.api.nvim_set_keymap(
      "n",
      "<leader>sc",
      "<cmd>Telescope scdoc<CR>",
      { desc = "[S]earch Super[C]ollider documentation" }
    )

    vim.api.nvim_create_autocmd("BufEnter", {
      once = true,
      callback = function()
        vim.cmd("SCNvimStart")
        vim.api.nvim_create_autocmd("ExitPre", {
          command = "SCNvimStop",
        })
      end,
    })
  end,
}
