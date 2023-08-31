local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  {
    "uga-rosa/ddu-source-search_history",
    dependencies = { "ddu.vim" },
    config = function()
      helper.setup("search-history", {
        sources = { { name = "search_history" } },
        kindOptions = {
          search_history = {
            defaultAction = "execute",
          },
        },
      }, "q/"
      )
    end,
  },

}
return spec
