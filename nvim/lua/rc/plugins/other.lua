---@type LazySpec
local spec = {
  {
    "monaqa/dial.nvim", -- increment
    event = "VeryLazy"
  },
  {
    "hrsh7th/nvim-insx", --bracket
  },
  {
    "chentoast/marks.nvim", -- marking
  },
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    config = function()
      local hlslens = require("hlslens")
      hlslens.setup({})
    end,
  },
  {
    "danymat/neogen", -- doc generator
  },
  {
    "mattn/vim-sonictemplate",
    cmd = { "Template" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.g.sonictemplate_key = 0
      vim.g.sonictemplate_intelligent_key = 0
      vim.g.sonictemplate_postfix_key = 0
      local Path = require("plenary.path")
      vim.g.sonictemplate_vim_template_dir = {
        Path:new(vim.fn.stdpath("config"), "template"):absolute(),
      }
    end,
    init = function()
      vim.keymap.set("n", "<leader>t", ":Template ")
    end,
  }
}

return spec
