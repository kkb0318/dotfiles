local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "Shougo/ddu-source-file_rec",
  dependencies = "ddu.vim",
  config = function()
    vim.fn["ddu#custom#patch_global"]({
      -- sourceOptions = {
      --   file_rec = {
      --     path = vim.fn.expand("~")
      --   }
      -- },
      --
    })
    helper.setup("hoge", {
        sources =
        {
          {
            name = 'file_rec',
            params = {}
          }
        }
      },
      "<leader>faf"
    )
  end,
}

return spec
