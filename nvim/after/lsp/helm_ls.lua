local config = {
  settings = {
    ['helm-ls'] = {
      yamlls = {
        path = "yaml-language-server",
      }
    }
  }
}

return {
  config = function(_)
    return config
  end,
}
