local config = {
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" },
}

return {
  config = function(_)
    return config
  end,
}
