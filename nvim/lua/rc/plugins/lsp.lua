local helper = require("helper.lsp")

---@type LazySpec
local spec = {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup()
        end,
      },
      "williamboman/mason-lspconfig.nvim",
      {
        "j-hui/fidget.nvim",
        tag = "legacy",
        config = function()
          require("fidget").setup()
        end,
      },
      "RRethy/vim-illuminate"
    },
    config = function()
      local lspconfig       = require("lspconfig")
      local lsp_servers     = {
        "gopls",
        "tsserver",
        "pyright",
        "yamlls",
        "cssls",
        "jsonls",
        "clangd",
        "terraformls",
        "rust_analyzer",
        "lua_ls",
        "helm_ls",
      }

      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup {
        automatic_installation = true,
        ensure_installed = lsp_servers
      }
      local tools = {
        -- Formatter
        "black",
        "flake8",
        "isort",
        "prettier",
        "jq",
        -- Linter
        "rstcheck",
        "eslint_d",
        "jsonlint",
      }
      -- ensure tools (except LSPs) are installed
      local mr = require("mason-registry")
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end

      mason_lspconfig.setup_handlers({
        function(server_name)
          local opts = helper.make_config(server_name)
          lspconfig[server_name].setup(opts)
        end,
      })
    end,
  },
}

return spec
