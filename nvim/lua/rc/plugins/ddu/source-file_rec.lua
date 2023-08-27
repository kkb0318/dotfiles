---@type LazySpec
local spec = {
  "Shougo/ddu-source-file_rec",
  dependencies = "ddu.vim",
  config = function()
    vim.fn["ddu#custom#patch_global"]({
      sources =
      {
        {
          name = 'file_rec',
          params = {}
        }
      }
      -- sourceOptions = {
      --   file_rec = {
      --     path = vim.fn.expand("~")
      --   }
      -- },
    })
  end,
}

return spec
