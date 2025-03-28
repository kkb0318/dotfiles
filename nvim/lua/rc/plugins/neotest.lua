local spec = {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      'nvim-neotest/neotest-go',
    },
    config = function()
      --   require("neotest").setup({
      --     adapters = {
      --       require("neotest-rust")
      --     }
      --   })
      require("neotest").setup({
        adapters = {
          require('rustaceanvim.neotest'),
          require('neotest-python')({
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG" },
            runner = "pytest",
            pytest_discover_instances = true,
          }),
          require('neotest-go'),
        },
      })
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap('n', '<leader>tn', ':lua require("neotest").run.run()<CR>', opts)
      vim.api.nvim_set_keymap('n', '<leader>tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', opts)
      vim.api.nvim_set_keymap('n', '<leader>ts', ':lua require("neotest").summary.toggle()<CR>', opts)
    end
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
  }
}

return spec
