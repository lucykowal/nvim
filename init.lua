-- ==================
-- lucy's nvim config
-- ==================

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- see `:help vim.opt`

-- disable spell checking, but add a toggle keymap to enable.
vim.o.spell = false
vim.o.spelllang = "en_us"
vim.keymap.set("n", "<leader>S", ":set spell!<CR>", { desc = "[S]pell check toggle" })

-- enable true color support
vim.o.termguicolors = true

-- window options
vim.o.ead = "ver"
vim.o.ea = true
vim.o.splitright = true
vim.o.splitbelow = true

-- qol/ux options
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300 -- for mapped sequences
vim.o.updatetime = 250
vim.o.undofile = true
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- ui options
vim.o.number = true
vim.o.signcolumn = "yes"
vim.o.breakindent = true
vim.o.inccommand = "split"
vim.o.list = true
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣", extends = "→", precedes = "←" }
vim.opt.cursorline = true
vim.o.scrolloff = 30

-- keymaps
-- see `:help vim.keymap`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<CS-H>", "<C-w>H", { desc = "Move window to the far left" })
vim.keymap.set("n", "<CS-L>", "<C-w>L", { desc = "Move window to the far right" })
vim.keymap.set("n", "<CS-J>", "<C-w>J", { desc = "Move window to the far top" })
vim.keymap.set("n", "<CS-K>", "<C-w>K", { desc = "Move window to the far bottom" })

-- autocommands
-- see `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Force help windows to the right",
  group = vim.api.nvim_create_augroup("help-win-right", { clear = true }),
  pattern = "*/doc/*",
  callback = function(ev)
    local rtp = vim.o.runtimepath
    local files = vim.fn.globpath(rtp, "doc/*", true, 1)
    if ev.file and vim.list_contains(files, ev.file) then
      -- entered a help file
      vim.api.nvim_set_option_value("filetype", "help", { scope = "local" })
      if vim.api.nvim_win_get_config(0).width > vim.o.columns * 0.5 then
        -- big enough to push right
        vim.cmd.wincmd("L")
        vim.cmd("vert resize " .. math.max(90, math.min(60, math.floor(vim.o.columns * 0.4))))
      end
    end
  end,
})

-- filetypes
vim.filetype.add({ extension = { frag = "glsl" } })
vim.filetype.add({ extension = { sc = "supercollider" } })

-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  ui = {
    border = require("settings").window.border,
    backdrop = 100,
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {},
  },
})
