---@type LazySpec
local spec = {
  {
    -- helm highlight
    "towolf/vim-helm"
  },
  {
    "mattn/vim-goaddtags", -- go add tags
    event = "VeryLazy"
  },
  {
    "aklt/plantuml-syntax", -- plantuml
    event = "VeryLazy"
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
}
return spec
