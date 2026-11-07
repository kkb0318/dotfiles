local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  error("lazy.nvim is missing. Run scripts/bootstrap-plugins.py to install the reviewed pins.")
end
local lockfile = vim.fn.stdpath("config") .. "/lua/plugins/lazy-lock.json"
local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
local pin = lock["lazy.nvim"] and lock["lazy.nvim"].commit
assert(type(pin) == "string" and #pin == 40 and pin:match("^[0-9a-f]+$"), "lazy.nvim must have a full SHA pin")
local head = vim.fn.system({ "git", "-C", lazypath, "rev-parse", "HEAD" })
assert(vim.v.shell_error == 0 and vim.trim(head) == pin,
  "lazy.nvim differs from its pin. Run scripts/bootstrap-plugins.py before starting Neovim.")
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("rc.plugins", {
  dev = {
    path = "~/.local/src",
  },
  change_detection = {
    enabled = false,
  },

  lockfile = lockfile,
  -- Missing plugins are restored explicitly, never fetched on normal startup.
  install = { missing = false },
  checker = { enabled = false },
  pkg = { enabled = false },
  rocks = { enabled = false },
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
