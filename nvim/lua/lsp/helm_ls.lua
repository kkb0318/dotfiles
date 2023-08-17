local config = {
  filetypes = { "helm" },
  cmd = { "helm_ls", "serve" },
}

return {
  config = function(_)
    return config
  end,
}
