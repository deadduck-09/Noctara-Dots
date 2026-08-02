return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    -- Mason
    mason.setup()

    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
      },
      automatic_installation = true,
    })

    -- Completion capabilities
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Diagnostic signs
    local signs = {
      Error = " ",
      Warn = " ",
      Hint = "󰠠 ",
      Info = " ",
    }

    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, {
        text = icon,
        texthl = hl,
        numhl = "",
      })
    end

    -- LSP keymaps
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "Code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Rename symbol"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Hover docs"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)
      end,
    })

    -- Lua LSP
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })

    -- Svelte LSP
    vim.lsp.config("svelte", {
      capabilities = capabilities,
      on_attach = function(client)
        vim.api.nvim_create_autocmd("BufWritePost", {
          pattern = { "*.js", "*.ts" },
          callback = function(ctx)
            client.notify("$/onDidChangeTsOrJsFile", {
              uri = ctx.match,
            })
          end,
        })
      end,
    })

    -- GraphQL
    vim.lsp.config("graphql", {
      capabilities = capabilities,
      filetypes = {
        "graphql",
        "gql",
        "svelte",
        "typescriptreact",
        "javascriptreact",
      },
    })

    -- Emmet
    vim.lsp.config("emmet_ls", {
      capabilities = capabilities,
      filetypes = {
        "html",
        "typescriptreact",
        "javascriptreact",
        "css",
        "sass",
        "scss",
        "less",
        "svelte",
      },
    })

    -- Default servers
    local servers = {
      "ts_ls",
      "html",
      "cssls",
      "tailwindcss",
      "prismals",
      "pyright",
    }

    for _, server in ipairs(servers) do
      vim.lsp.config(server, {
        capabilities = capabilities,
      })
    end

    -- Enable all servers
    vim.lsp.enable({
      "lua_ls",
      "ts_ls",
      "html",
      "cssls",
      "tailwindcss",
      "svelte",
      "graphql",
      "emmet_ls",
      "prismals",
      "pyright",
    })
  end,
}
