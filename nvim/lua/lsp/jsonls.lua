local config = {
  filetypes = { "json", "jsonc", "json5" },
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
      format = { enable = true },
    }
  }
}

return {
  config = function(_)
    return config
  end,
}
