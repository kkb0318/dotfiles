---@type LazySpec
local spec = {
  {
    "monaqa/dial.nvim", -- increment
    event = "VeryLazy"
  },
  {
    "hrsh7th/nvim-insx", --bracket
  },
  {
    "chentoast/marks.nvim", -- marking
  },
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    config = function()
      local hlslens = require("hlslens")
      hlslens.setup({})
    end,
  },
  {
    "danymat/neogen", -- doc generator
  },
}

return spec
