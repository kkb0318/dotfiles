---@type LazySpec
local spec = {
  "Shougo/ddu.vim",
  name = "ddu.vim",
  dependencies = "vim-denops/denops.vim",
  import = "rc.plugins.ddu",
  config = function()
    -- vim.schedule(vim.fn["ddu#start"])
  end,
}

return spec
