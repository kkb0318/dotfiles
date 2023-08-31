---@type LazySpec
local spec = {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local tele_actions = require("telescope.actions")
    local fb_actions = require "telescope".extensions.file_browser.actions
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = tele_actions.close,
          },
          n = {
            ["q"] = tele_actions.close
          },
        },
      },
      pickers = {
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end
        },
      },
      extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            -- your custom insert mode mappings
            ["i"] = {
              ["<C-w>"] = function() vim.cmd('normal vbd') end,
            },
            ["n"] = {
              -- your custom normal mode mappings
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd('startinsert')
              end
            },
          },
        },
      },
    })
    telescope.load_extension("file_browser")

    local builtin = require("telescope.builtin")
    local function telescope_buffer_dir()
      return vim.fn.expand('%:p:h')
    end
    -- vim.keymap.set('n', ';f',
    --   function()
    --     builtin.find_files({
    --       no_ignore = false,
    --       hidden = true
    --     })
    --   end)
    -- vim.keymap.set('n', ';r', function()
    --   builtin.live_grep()
    -- end)
    vim.keymap.set('n', '\\\\', function()
      builtin.buffers()
    end)
    -- vim.keymap.set('n', ';t', function()
    --   builtin.help_tags()
    -- end)
    -- vim.keymap.set('n', ';;', function()
    --   builtin.resume()
    -- end)
    vim.keymap.set('n', ';e', function()
      builtin.diagnostics()
    end)
    vim.keymap.set("n", "sf", function()
      telescope.extensions.file_browser.file_browser({
        path = "%:p:h",
        cwd = telescope_buffer_dir(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        previewer = false,
        initial_mode = "normal",
        layout_config = { height = 40 }
      })
    end)
  end,
}
return spec
