local config = {
  settings = {
        ['rust-analyzer'] = {
      diagnostics = {
        enable = false,
      }
    }
  }
}

return {
  config = function(_)
    return config
  end,
}
