---@type LazySpec
local spec = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },
  -- {
  --   "bluz71/vim-nightfly-colors",
  --   name = "nightfly",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.nightflyItalics = false
  --     vim.cmd.colorscheme("nightfly")
  --     local palette = require("nightfly").palette
  --
  --     vim.api.nvim_set_hl(0, "NormalFloat", { bg = palette.black })
  --     vim.api.nvim_set_hl(0, "FloatBorder", { fg = palette.white, bg = palette.black })
  --     vim.api.nvim_set_hl(0, "PmenuSel", { bg = palette.cyan_blue })
  --     vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })
  --   end,
  -- },
}

return spec
