local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("rc.plugins", {
  dev = {
    path = "~/.local/src",
  },
  change_detection = {
    enabled = false,
  },

  lockfile = vim.fn.stdpath("config") .. "/lua/plugins/lazy-lock.json",
  -- ui = {
  --   size = { width = 0.8, height = 0.8 },
  --   wrap = true,
  --   border = "shadow",
  -- },
  -- performance = {
  --   cache = {
  --     enabled = true,
  --   },
  --   reset_packpath = true,
  --   rtp = {
  --     disabled_plugins = {
  --       "gzip",
  --       "matchparen",
  --       "netrwPlugin",
  --       "tarPlugin",
  --       "tohtml",
  --       "tutor",
  --       "zipPlugin",
  --     },
  --   },
  -- },
})
