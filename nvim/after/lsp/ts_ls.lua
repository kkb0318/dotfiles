local _, util = pcall(require, "lspconfig/util")
local config = {
  root_dir = util.root_pattern("package.json"),
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" },
  single_file_support = false,
}

return {
  config = function(_)
    return config
  end,
}
