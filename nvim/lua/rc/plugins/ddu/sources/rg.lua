local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "shun/ddu-source-rg",
  dependencies = "ddu.vim",
  config = function()
    helper.setup("file_lg", {
        uiParams = {
          ff = {
            ignoreEmpty = false,
          },
        },
        sources = { {
          name = "rg",
          params = { args = { "--json" } }
        } },
        sourceOptions = {
          rg = {
            volatile = true,
            matchers = {},
          },
        },
      },
      ";r"
    )
  end
}

return spec
