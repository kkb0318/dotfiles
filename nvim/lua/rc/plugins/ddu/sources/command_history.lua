local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  {
    "matsui54/ddu-source-command_history",
    dependencies = { "ddu.vim" },
    config = function()
      helper.setup("command-history", {
        sources = { { name = "command_history" } },
        kindOptions = {
          command_history = {
            defaultAction = "execute",
          },
        },
      }, "q:"
      )
    end,
  },
}
return spec
