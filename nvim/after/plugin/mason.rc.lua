local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end



local lsp_servers = {
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

mason.setup({
})

lspconfig.setup {
  automatic_installation = true,
  ensure_installed = lsp_servers
}



-- ensure tools (except LSPs) are installed
local mr = require("mason-registry")
for _, tool in ipairs(tools) do
  local p = mr.get_package(tool)
  if not p:is_installed() then
    p:install()
  end
end
