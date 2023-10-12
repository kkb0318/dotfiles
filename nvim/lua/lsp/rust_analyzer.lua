local config = {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false,
      },
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
        features = "all",
      },
      procMacro = {
        enable = true
      },
    }
  }
}

return {
  config = function(_)
    return config
  end,
}
