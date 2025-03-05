local settings = require("settings")

return { -- telescope, incredibly powerful fuzzy finder
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { -- faster fuzzy find
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { -- file browser
      "nvim-telescope/telescope-file-browser.nvim",
    },
    { -- replace ui-select
      "nvim-telescope/telescope-ui-select.nvim",
    },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    { -- supercollider docs
      "davidgranstrom/telescope-scdoc.nvim",
    },
    { -- recent/frequent files
      "nvim-telescope/telescope-frecency.nvim",
      -- install the latest stable version
      version = "*",
      config = function()
        vim.keymap.set("n", "<leader>sf", function()
          require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
        end, { desc = "[S]earch [F]iles" })
      end,
    },
  },
  config = function()
    -- see `:help telescope` and `:help telescope.setup()`
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        sorting_strategy = "ascending",
        selection_strategy = "closest",
        layout_config = {
          horizontal = {
            anchor = "N",
            prompt_position = "top",
            height = settings.window.height,
            width = settings.window.width,
            preview_width = { 0.5, max = 40, min = 16 },
          },
        },
        path_display = {
          truncate = 2,
          shorten = { len = 3, exclude = { -1, -2 } },
        },
        initial_mode = "normal",
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        mappings = { -- See `:help telescope.actions`
          i = {
            ["<C-y"] = require("telescope.actions").select_default,
          },
          n = {
            ["q"] = require("telescope.actions").close,
            ["<C-n>"] = require("telescope.actions").move_selection_next,
            ["<C-p>"] = require("telescope.actions").move_selection_previous,
            ["<C-y"] = require("telescope.actions").select_default,
          },
        },
        dynamic_preview_title = true,
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
        buffers = {
          mappings = {
            n = {
              ["d"] = require("telescope.actions").delete_buffer + require("telescope.actions").move_to_top,
            },
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({
            layout_config = {
              anchor = "N",
            },
            borderchars = {
              { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
              prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
              results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
              preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            },
          }),
        },
        ["scdoc"] = {},
      },
    })

    -- enable extensions if they are installed
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
    pcall(telescope.load_extension, "file_browser")
    pcall(telescope.load_extension, "frecency")
    pcall(telescope.load_extension, "scdoc")

    -- keymaps
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set(
      "n",
      "<leader>/",
      builtin.current_buffer_fuzzy_find,
      { desc = "[/] Fuzzily search in current buffer" }
    )
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[S]earch [/] in Open Files" })

    vim.keymap.set("n", "<leader>fb", telescope.extensions.file_browser.file_browser, { desc = "[F]ile [B]rowser" })
    vim.keymap.set("n", "<leader>ff", function()
      telescope.extensions.file_browser.file_browser({
        path = vim.fn.expand("%:p:h"),
        select_buffer = true,
      })
    end, { desc = "[F]ile browser at [F]ile" })
  end,
}
