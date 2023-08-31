local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  {
    "matsui54/ddu-source-file_external",
    dependencies = { "ddu.vim", "ddu-kind-file" },
    config = function()
      helper.setup("file-external", {
          sources = { {
            name = "file_external",
            params = { cmd = { "rg", "--files", "--color", "never" } },
          } },
        },
        ";f"
      )
    end,
  },
}

return spec
