local helper = require("helpers.ddu")
---@type LazySpec
local spec = { {
  "https://github.com/kkb0318/ddu-source-git_worktree",
  dependencies = { "Shougo/ddu.vim" },
  config = function()
    helper.patch_global({
      kindOptions = {
        git_worktree = {
          defaultAction = "switch",
        },
      },
      sourceParams = {
        git_worktree = {
          defaultPath = '../worktrees/{repo}/{branch}',
        },
      },
    })

    helper.setup("git_worktree", {
        sources = { {
          name = "git_worktree",
        } },
      },
      "<space>gw"
    )

    vim.api.nvim_create_autocmd("FileType", {
      -- group を指定しない
      pattern = "ddu-ff",
      callback = function()
        local ddu_name = vim.b.ddu_ui_name
        if ddu_name ~= "git_worktree" then
          return
        end

        local opts = { buffer = true, silent = true, nowait = true }
        vim.keymap.set("n", "<CR>", helper.item_action("switch"), opts)
        vim.keymap.set("n", "d", helper.item_action("delete"), opts)
        vim.keymap.set("n", "D", helper.item_action("forceDelete"), opts)
        vim.keymap.set("n", "c", helper.item_action("create"), opts)
        vim.keymap.set("n", "p", helper.action("preview"), opts)
        vim.keymap.set("n", "q", helper.action("quit"), opts)
      end,
    })
  end,
} }
return spec
