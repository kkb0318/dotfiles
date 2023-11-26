---@type LazySpec
local spec = {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    event = "BufReadPre",
  },
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    event = "BufReadPre",
  }

}
return spec
