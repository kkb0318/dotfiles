local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "matsui54/ddu-source-help",
  dependencies = "ddu.vim",
  config = function()
    helper.setup("help", {
      sources = { { name = "help" } },
      kindOptions = {
        help = {
          defaultAction = "open",
        },
      },
    }, ";h")
  end
}

return spec
