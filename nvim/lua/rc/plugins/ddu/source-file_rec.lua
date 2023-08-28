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
      --
    })
    local hoge = "hoge"
    vim.fn["ddu#custom#patch_local"](hoge, {
      sources =
      {
        {
          name = 'file_rec',
          params = {}
        }
      }
    }
    )
    vim.keymap.set("n", "<leader>faf", function()
      vim.fn["ddu#start"]({ name = hoge })
    end, { remap = false, desc = "Start ddu: " .. hoge })

  end,
}

return spec
