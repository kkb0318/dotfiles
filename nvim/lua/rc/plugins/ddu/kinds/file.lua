local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "Shougo/ddu-kind-file",
  dependencies = "ddu.vim",
  config = function()
    helper.patch_global({
      kindOptions = {
        file = {
          defaultAction = "open",
        },
      },
    })
  end,
}

return spec
