---@type LazySpec
local spec = {
  {
    "Shougo/ddu.vim",
    name = "ddu.vim",
    dependencies = "vim-denops/denops.vim",
    config = function()
      -- vim.schedule(vim.fn["ddu#start"])
    end
  },
  { import = "rc.plugins.ddu.sources" },
  { import = "rc.plugins.ddu.filters" },
  { import = "rc.plugins.ddu.kinds" },
  { import = "rc.plugins.ddu.ui" },

}

return spec
