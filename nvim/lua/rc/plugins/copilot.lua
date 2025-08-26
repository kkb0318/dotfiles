---@type LazySpec
local spec = {
  {
    "github/copilot.vim",
    config = function()
      vim.api.nvim_set_keymap("i", "<C-J>", "copilot#Accept(\"<CR>\")", { silent = true, expr = true })
      vim.g.copilot_no_tab_map = true
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = { "VeryLazy" },
    branch = "main",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      model = "gpt-5", -- モデル名を指定
      debug = true,    -- デバッグを有効化
    },
  }

}
return spec
