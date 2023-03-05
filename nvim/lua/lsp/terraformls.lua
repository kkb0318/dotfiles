local config = {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "tf" },
  settings = {
    telemetry = {
      enable = false
    }
  }
}

return {
  config = function(_)
    return config
  end,
}
