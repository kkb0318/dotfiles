local config = {
  offset_encoding = "utf-8",
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
