-- co-pilot and related plugins
local settings = require("settings")

-- helper to get an ollama config for any URL
local ollama_provider = function(host)
  return {
    embed = "copilot_embeddings",
    prepare_input = require("CopilotChat.config.providers").copilot.prepare_input,
    prepare_output = require("CopilotChat.config.providers").copilot.prepare_output,

    get_models = function(headers)
      local response, err = require("CopilotChat.utils").curl_get(host .. "/api/tags", {
        headers = headers,
        json_response = true,
      })

      if err then
        vim.notify(err, vim.log.levels.ERROR)
        response = { body = { models = {} } }
      end

      return vim.tbl_map(function(model)
        return {
          id = model.name,
          name = model.name,
        }
      end, response.body.models)
    end,

    get_url = function()
      return host .. "/api/chat"
    end,
  }
end

local function register_cmp()
  -- register cmp source to override complete
  local copilot = require("CopilotChat")
  local cmp = require("cmp")
  local comp_tbl = copilot.complete_info()
  local source = {
    get_keyword_pattern = function()
      return comp_tbl.pattern
    end,
    get_trigger_characters = function()
      return comp_tbl.triggers
    end,
    complete = function(_, _, callback)
      local items = copilot.complete_items()
      local mapped_items = vim.tbl_map(function(i)
        return { label = i.word, kind = cmp.lsp.CompletionItemKind.Reference }
      end, items)
      callback(mapped_items)
    end,
    execute = function(_, item, callback)
      callback(item)
      -- vim.api.nvim_set_option_value("buflisted", false, { buf = 0 })
    end,
  }
  cmp.register_source("copilot-chat", source)
  cmp.setup.filetype("copilot-chat", {
    sources = {
      { name = "path" },
      {
        name = "dictionary",
        keyword_length = 2,
        max_item_count = 5,
      },
      {
        name = "copilot-chat",
        keyword_length = 0,
      },
    },
  })
end

return {
  { -- co-pilot
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
          auto_trigger = true,
          keymap = {
            accept = "<C-y>",
            accept_word = false,
            accept_line = false,
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<C-e>",
          },
        },
        filetypes = {
          markdown = true,
        },
        copilot_node_command = "node",
      })
    end,
    dependencies = {},
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
  },
  { -- local completions
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    cond = settings.ollama_host ~= nil,
    opt = {
      provider = "openai_fim_compatible",
      context_window = 512,
      n_completions = 2,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = (settings.ollama_host or "") .. ":11434/v1/completions",
          model = "qwen2.5-coder:1.5b-base-q3_K_S",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
    },
  },
  { -- chat with copilot
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    keys = { "<leader>g", nil },
    build = "make tiktoken", -- Only on MacOS or Linux
    config = function()
      local chat = require("CopilotChat")
      register_cmp()

      chat.setup({
        window = {
          layout = "replace",
          -- width = 0.4,
        },
        highlight_headers = false,
        insert_at_end = true,
        chat_autocomplete = false,
        mappings = {
          complete = {
            insert = "<Tab>",
            callback = function(_)
              require("cmp").complete({
                config = {
                  sources = {
                    { name = "copilot-chat" },
                  },
                },
              })
            end,
          },
          accept_diff = {
            normal = "<C-a>",
            insert = "<C-a>",
          },
        },
        model = "claude-3.5-sonnet",
        providers = settings.ollama_host
            and {
              ollama = ollama_provider("http://localhost:11434"),
              -- TODO: Add on command
              -- ollama_ubuntu = ollama_provider(settings.ollama_host .. ":11434"),
              github_models = nil,
              copilot_embeddings = nil,
            }
          or {
            github_models = nil,
            copilot_embeddings = nil,
          },
      })

      -- more customized open panel logic
      vim.keymap.set({ "n", "v" }, "<leader>g", function()
        chat.open({
          window = {
            layout = vim.api.nvim_win_get_width(0) * 0.4 > vim.api.nvim_win_get_height(0) and "vertical"
              or "horizontal",
          },
        })
      end, { desc = "[G]oto Copilot" })

      vim.keymap.set("n", "<leader>ccp", function()
        local actions = require("CopilotChat.actions")
        -- TODO: update per deprecation
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end, { desc = "CopilotChat - Prompt actions" })
    end,
  },
}
