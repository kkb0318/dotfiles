---@type LazySpec
local spec = {
  {
    "folke/zen-mode.nvim",
    init = function()
      vim.keymap.set('n', '<C-w>o', '<cmd>ZenMode<cr>', { silent = true })
    end,
    config = function()
      require("zen-mode").setup({
      })
    end
  },
}

return spec
