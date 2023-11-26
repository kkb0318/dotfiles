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
    "mattn/vim-maketable", --markdown
    event = "VeryLazy"
  },
  {
    "iamcco/markdown-preview.nvim", --markdown
    run = function() vim.fn["mkdp#util#install"]() end,
    event = "VeryLazy"
  },
  {
    "aklt/plantuml-syntax", -- plantuml
    event = "VeryLazy"
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
