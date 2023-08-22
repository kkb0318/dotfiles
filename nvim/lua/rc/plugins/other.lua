---@type LazySpec
local spec = {
  {
    "monaqa/dial.nvim", -- increment
  },
  {
    "hrsh7th/nvim-insx", --bracket
  },
  {
    "mattn/vim-maketable", --markdown
  },
  {
    "iamcco/markdown-preview.nvim", --markdown
    run = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "aklt/plantuml-syntax", -- plantuml
  },
  {
    "chentoast/marks.nvim", -- marking
  },
  {
    "kevinhwang91/nvim-hlslens", -- search
  },
}

return spec
