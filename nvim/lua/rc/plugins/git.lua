---@type LazySpec
local spec = {
  {
    "lambdalisue/vim-gin",
    event = { "User DenopsReady" },
    dependencies = { "vim-denops/denops.vim" },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},

  },
}
return spec
