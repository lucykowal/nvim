local settings = require("settings")

local function get_jdtls_root()
  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
  return vim.fs.root(0, root_markers)
end

if false then
  local co = coroutine.running()
  local cb = function() end
  if co then
    cb = function(i)
      coroutine.resume(co, i)
    end
  end
  cb = vim.schedule_wrap(cb)
  vim.ui.select({ "a", "b", "c" }, { prompt = "Select one" }, cb)
  if co then
    print(coroutine.yield(co))
  end
end

local function get_jdtls_cmd()
  local home = vim.fn.getenv("HOME")

  local project_name = vim.fn.fnamemodify(get_jdtls_root(), ":p:h:t")
  local workspace_dir = home .. "/.cache/jdtls/workspace" .. project_name

  local mason_packages = require("mason.settings").current.install_root_dir .. "/packages"

  local jdtls_path = mason_packages .. "/jdtls"
  local jdebug_path = mason_packages .. "/java-debug-adapter"
  local jtest_path = mason_packages .. "/java-test"

  local config_type = "/config_mac" .. (vim.uv.os_uname().machine == "x86_64" and "" or "_arm")
  local config_path = jdtls_path .. config_type
  local lombok_path = mason_packages .. "/lombok-nightly/lombok.jar"

  local jar_path = jdtls_path .. "/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar"

  local bundles = {
    vim.fn.glob(jdebug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
  }
  vim.list_extend(bundles, vim.split(vim.fn.glob(jtest_path .. "/extension/server/*.jar", true), "\n"))

  return {
    -- NOTE: you must set $JAVA_HOME to `/usr/libexec/java_home -v 21`
    vim.fn.getenv("JAVA_HOME") .. "/bin/java",

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "-javaagent:" .. lombok_path,
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    "-jar",
    jar_path,

    "-configuration",
    config_path,

    "-data",
    workspace_dir,
  }
end

return {
  -- Main LSP Configuration
  "neovim/nvim-lspconfig",
  dependencies = {
    { -- NOTE: Must be loaded before dependants
      "williamboman/mason.nvim",
      config = true,
    },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    "mfussenegger/nvim-dap",
    "jay-babu/mason-nvim-dap.nvim",

    { -- Status updates, notifications
      "j-hui/fidget.nvim",
      -- NOTE: check for updates once this PR is merged:
      commit = "749744e2434ff60254c90651c18226d95decc796",
      event = "UIEnter",
      opts = {
        progress = {
          suppress_on_insert = true,
          ignore_done_already = true,
          display = {
            render_limit = 8,
            done_ttl = 1,
          },
        },
        notification = {
          override_vim_notify = true,
          view = {
            stack_upwards = false,
          },
          window = {
            winblend = settings.window.winblend,
            border = settings.window.border,
            max_width = math.floor(settings.window.width() * 0.5),
            x_padding = 1,
            align = "top",
          },
        },
      },
    },
    "hrsh7th/cmp-nvim-lsp",
    {
      "lucykowal/nvim-jdtls-ui",
      dev = true,
    },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(attach_event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = attach_event.buf, desc = "LSP: " .. desc })
        end

        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>cd", require("telescope.builtin").lsp_document_symbols, "[C]ode [D]ocument symbols")
        map("<leader>cw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[C]ode [W]orkspace symbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

        -- Usually apply to errors
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Setup symbol highlights on cursor hold
        -- See `:help CursorHold`
        local client = vim.lsp.get_client_by_id(attach_event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = attach_event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = attach_event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
            callback = function(detach_event)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = detach_event.buf })
            end,
          })
        end
      end,
    })

    -- replace the default floating preview with a custom one
    local orig_open_floating_preview = vim.lsp.util.open_floating_preview
    ---@diagnostic disable-next-line: duplicate-set-field
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      local borderchars = {
        { "┌", "FloatBorder" },
        { "─", "FloatBorder" },
        { "┐", "FloatBorder" },
        { "│", "FloatBorder" },
        { "┘", "FloatBorder" },
        { "─", "FloatBorder" },
        { "└", "FloatBorder" },
        { "│", "FloatBorder" },
      }
      opts = opts or {}
      ---@diagnostic disable-next-line: inject-field
      opts.border = opts.border or borderchars
      return orig_open_floating_preview(contents, syntax, opts, ...)
    end

    -- Change diagnostic symbols in the sign column (gutter)
    if vim.g.have_nerd_font then
      local signs = { Error = "", Warn = "", Hint = "", Info = "" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end

    -- broadcast cmp capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    --  required lsps with overridable configs
    --  - cmd (table): Command to start server
    --  - filetypes (table): filetypes to attach to the server
    --  - capabilities (table): change capabilities
    --  - settings (table): default settings - i.e. args
    local servers = {
      -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = { disable = { "missing-fields" } },
          },
        },
      },
      jdtls = {
        cmd = get_jdtls_cmd(),
        root_dir = get_jdtls_root(),
        filetypes = { "java" },
        handlers = require("lspconfig.configs.jdtls").default_config.handlers,
        settings = {
          java = {
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = false,
            },
            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
            signatureHelp = {
              enabled = true,
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "sun.*",
            },
            importOrder = {
              "java",
              "javax",
              "com",
              "org",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
      },
      gopls = {},
      yamlls = { -- NOTE: requires `yarn`
        settings = {
          redhat = {
            telemetry = { enabled = false },
          },
        },
      },
      cssls = {}, -- NOTE: requires `npm`
      html = {},
      harper_ls = { -- check grammar
        filetypes = { "markdown" },
      },
    }

    -- see :Mason to manage
    require("mason").setup({
      ui = {
        border = settings.window.border,
        backdrop = 100,
        width = settings.window.width(),
        height = settings.window.height(),
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:nvim-java/mason-registry",
      },
    })

    -- tools beyond lspconfig for mason to install
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua",
      "google-java-format",
      "prettier",
      "java-debug-adapter",
      "java-test",
      "lombok-nightly",
    })
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- set capabilities with force to use above `server` configs
          server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
          require("lspconfig")[server_name].setup(server)
        end,
        ["harper_ls"] = function(_)
          local server = servers["harper_ls"]
          server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
          require("lspconfig").harper_ls.setup(server)
          -- like normal, but bump the diagnostic level
          local nss = vim.diagnostic.get_namespaces()
          local ns = nil
          for i, d in ipairs(nss) do
            if vim.startswith(d.name, "vim.lsp.harper_ls") then
              ns = i
            end
          end
          vim.diagnostic.config({ virtual_text = { severity = vim.diagnostic.severity.ERROR } }, ns)
        end,
        ["jdtls"] = function(_)
          -- no-op, use autocommand instead for java
        end,
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        require("jdtls").start_or_attach(servers.jdtls, {
          ui = {
            pick_one = function(items, prompt, label_fn)
              local co = coroutine.running()
              local cb = function() end
              if co then
                cb = function(i)
                  coroutine.resume(co, i)
                end
              end
              cb = vim.schedule_wrap(cb)
              vim.ui.select(items, { prompt = prompt, label_fn = label_fn }, cb)
              if co then
                return coroutine.yield(co)
              end
              return nil
            end,
            pick_one_async = function(items, prompt, label_fn, cb)
              vim.ui.select(items, { prompt = prompt, label_fn = label_fn }, function()
                cb()
              end)
            end,
          },
        })
      end,
    })
  end,
}
