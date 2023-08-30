local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "Shougo/ddu-filter-matcher_substring",
  dependencies = "ddu.vim",
  config = function()
    helper.patch_global({
      sourceOptions = {
        _ = {
          matchers = { "matcher_substring" }
        }
      }
    })
  end,
}

return spec
