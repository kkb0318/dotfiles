local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "Shougo/ddu-ui-ff",
  dependencies = "ddu.vim",
  config = function()
    helper.patch_global({
      ui = "ff",
      uiParams = {
        ff = {
          startFilter = true,
          prompt = "> ",
          split = "floating",
          floatingBorder = "single",
          filterFloatingPosition = "top",
          autoAction = {
            name = "preview",
          },
          startAutoAction = true,
          previewFloating = true,
          ignoreEmpty = true,
        },
      },
    })
  end,
}

return spec
