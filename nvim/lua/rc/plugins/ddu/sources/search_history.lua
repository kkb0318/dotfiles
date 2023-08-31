local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  {
    "uga-rosa/ddu-source-search_history",
    dependencies = { "ddu.vim" },
    config = function()
      helper.setup("search_history", {
        sources = { { name = "search_history" } },
        kindOptions = {
          _ = {
            defaultAction = "execute",
          },
        },
      }, "q/"
      )
    end,
  },

}
return spec
