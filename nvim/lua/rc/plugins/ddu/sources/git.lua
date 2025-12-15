local helper = require("helpers.ddu")

---@type LazySpec
local spec = { {
  "https://github.com/kuuote/ddu-source-git_status",
  dependencies = { "Shougo/ddu.vim" },
  config = function()
    helper.setup("git_status", {
        sources = { {
          name = "git_status",
        } },
      },
      "<space>gs"
    )
  end,
}
}
return spec
