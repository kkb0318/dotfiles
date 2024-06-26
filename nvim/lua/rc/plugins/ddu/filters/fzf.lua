local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "yuki-yano/ddu-filter-fzf",
  dependencies = {
    "ddu.vim",
  },
  config = function()
    helper.patch_global({
      sourceOptions = {
        _ = {
          matchers = { "matcher_fzf" },
          sorters = { "sorter_fzf" },
        },
      },
      filterParams = {
        matcher_fzf = {
          highlightMatched = "Search",
        },
      },
    })
  end,
}

return spec
