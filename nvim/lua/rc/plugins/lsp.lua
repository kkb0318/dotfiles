local helper = require("helpers.lsp")

---@type LazySpec
local spec = {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup()
        end,
      },
      -- "williamboman/mason-lspconfig.nvim",
      {
        "j-hui/fidget.nvim",
        config = function()
          require("fidget").setup()
        end,
      },
      {
        "RRethy/vim-illuminate",
        config = function()
          helper.on_attach(function(client, _)
            require("illuminate").on_attach(client)
          end)
        end,
      },
      {
        "glepnir/lspsaga.nvim",
      },
      "b0o/schemastore.nvim", -- for jsonls schema
    },
    init = function()
      helper.on_attach(function(client, bufnr)
        local exclude_ft = { "oil" }
        local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        if vim.tbl_contains(exclude_ft, ft) then
          return
        end
        helper.my_on_attach(client, bufnr)
        vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
      end)
    end,

    config = function()
      local lsp_servers     = {
        -- "phpactor",
        "gopls",
        "ts_ls",
        "efm",
        "pyright",
        "yamlls",
        "cssls",
        "denols",
        "jsonls",
        "clangd",
        "terraformls",
        -- "rust_analyzer", -- installed via rustaceanvim. See https://github.com/mrcjkb/rustaceanvim?tab=readme-ov-file#zap-quick-setup
        "lua_ls",
        "ruff",
        "helm_ls",
      }

      local tools = {
        -- Formatter
        "prettier",
        "jq",
        -- Linter
        "rstcheck",
        "eslint_d",
        "jsonlint",
      }

      vim.lsp.enable(tools)
      vim.lsp.enable(lsp_servers)

      -- ensure tools (except LSPs) are installed
      local mr    = require("mason-registry")
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end

      -- LSP Saga settings
      local saga = require("lspsaga")
      saga.setup {
        symbol_in_winbar = {
          enable = false
        },
        lightbulb = {
          enable = false
        },
      }
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<C-j>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
      vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
      vim.keymap.set('n', 'gd', '<Cmd>Lspsaga lsp_finder<CR>', opts)
      -- vim.keymap.set('i', '<C-k>', '<Cmd>Lspsaga signature_help<CR>', opts)
      vim.keymap.set('i', '<C-k>', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
      vim.keymap.set('n', 'gp', '<Cmd>Lspsaga peek_definition<CR>', opts)
      vim.keymap.set('n', 'gr', '<Cmd>Lspsaga rename<CR>', opts)
    end,
  },
}

return spec
