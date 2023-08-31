local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  {
    "Shougo/ddu-source-file_rec",
    dependencies = { "ddu.vim", "ddu-kind-file" },
    config = function()
      helper.setup("hoge", {
          sources =
          {
            {
              name = 'file_rec',
            }
          }
        },
        "<leader>faf"
      )
    end,
  },
  {
    "matsui54/ddu-source-file_external",
    dependencies = { "ddu.vim", "ddu-kind-file" },
    config = function()
      helper.setup("file-hide", {
          sources = { {
            name = "file_external",
            params = { cmd = { "rg", "--files", "--color", "never" } },
          } },
        },
        "<leader>ff"
      )
    end,
  },

}

return spec
