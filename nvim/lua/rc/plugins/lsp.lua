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
          -- Keep Nix-provided tools ahead of any previously installed binaries.
          require("mason").setup({ PATH = "append" })
        end,
      },
      -- "williamboman/mason-lspconfig.nvim",
      {
        "j-hui/fidget.nvim",
        config = function()
          require("fidget").setup()
        end,
      },
      "RRethy/vim-illuminate",
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
        helper.enable_format_on_save(client, bufnr)
        helper.on_attach_keymap(client, bufnr)
        vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
      end)
    end,

    config = function()
      local lsp_servers = {
        -- "phpactor",
        "gopls",
        "ts_ls",
        "efm",
        "yamlls",
        "cssls",
        "jsonls",
        "clangd",
        "terraformls",
        -- "rust_analyzer", -- installed via rustaceanvim. See https://github.com/mrcjkb/rustaceanvim?tab=readme-ov-file#zap-quick-setup
        "lua_ls",
        "ruff",
        "helm_ls",
      }

      vim.lsp.enable(lsp_servers)
      -- External tools are selected explicitly in Nix (or a project shell).
      -- Opening a file must not download the latest formatter/linter via Mason.

      -- LSP Saga settings
      local saga = require("lspsaga")
      saga.setup {
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
