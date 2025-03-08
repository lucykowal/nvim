-- cmp autocomplete
local settings = require("settings")

return { -- autocomplete
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    { -- snippets in nvim-cmp
      "L3MON4D3/LuaSnip",
      build = (function()
        -- build for regex support in snippets
        return "make install_jsregexp"
      end)(),
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
    },
    { -- dictionary recommendations
      "uga-rosa/cmp-dictionary",
      name = "cmp_dictionary",
      ft = { "markdown", "copilot-chat" },
      config = function()
        require("cmp_dictionary").setup({
          paths = { "/usr/share/dict/words" },
          exact_length = 2,
        })
      end,
    },

    "zbirenbaum/copilot-cmp",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-buffer",
  },
  config = function()
    -- See `:help cmp`
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    luasnip.config.setup({})

    cmp.setup({
      performance = {
        max_view_entries = 20,
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete({}), -- trigger completion
        ["<C-l>"] = cmp.mapping(function() -- move forward in snippet
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function() -- and backwards
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { "i", "s" }),
      }),
      sources = {
        {
          name = "lazydev",
          group_index = 0, -- skip loading completions
        },
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
      },
      window = {
        completion = cmp.config.window.bordered({
          focusable = false,
          winblend = 100,
          border = settings.window.border,
        }),
        documentation = cmp.config.window.bordered({
          winblend = 0,
          border = settings.window.border,
        }),
      },
    })

    -- custom cmp confs
    local path_dict_fts = { "html", "markdown" }
    for _, ft in ipairs(path_dict_fts) do
      cmp.setup.filetype(ft, {
        sources = {
          { name = "path" },
          {
            name = "dictionary",
            keyword_length = 2,
            max_item_count = 5,
          },
        },
      })
    end

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
      matching = { disallow_symbol_nonprefix_matching = false },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
      matching = { disallow_symbol_nonprefix_matching = false },
    })
  end,
}
