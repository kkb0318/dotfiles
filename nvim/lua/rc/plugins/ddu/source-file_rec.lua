local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
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
      "<leader>ff"
    )
  end,
}

return spec
