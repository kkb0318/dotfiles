local _, util = pcall(require, "lspconfig/util")
local config = {
  root_dir = util.root_pattern("package.json"),
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" },
  single_file_support = false,
  on_init = function(client)
    -- ts_lsのフォーマット機能を無効化（on_attachより先に実行される）
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}

return {
  config = function(_)
    return config
  end,
}
