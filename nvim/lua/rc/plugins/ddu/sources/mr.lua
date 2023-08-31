local helper = require("helpers.ddu")

---@type LazySpec
local spec = { {
  "lambdalisue/mr.vim",
  lazy = true,
}, {
  "kuuote/ddu-source-mr",
  dependencies = { "ddu.vim", "ddu-kind-file", "mr.vim" },
  config = function()
    helper.setup("mrw", {
      sources = { { name = "mr", params = { kind = "mrw" } } },
      },
      "<leader>mw"
    )
    helper.setup("mrr", {
      sources = { { name = "mr", params = { kind = "mrr" } } },
      },
      "<leader>mr"
    )
    helper.setup("mru", {
      sources = { { name = "mr", params = { kind = "mru" } } },
      },
      "<leader>mu"
    )
  end,
} }
return spec

