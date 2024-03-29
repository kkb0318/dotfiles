local status, util = pcall(require, "lspconfig/util")
if (not status) then return end
local config = {
  cmd = { "gopls", "serve" },
  filetypes = { "go", "gomod" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

return {
  config = function(_)
    return config
  end,
}
