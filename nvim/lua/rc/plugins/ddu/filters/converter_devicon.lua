local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "uga-rosa/ddu-filter-converter_devicon",
  dependencies = "ddu.vim",
  config = function()
    helper.setup("file", {
      sourceOptions = {
        _ = {
          converters = { "converter_devicon" },
        },
      },
    })
  end,
}

return spec
