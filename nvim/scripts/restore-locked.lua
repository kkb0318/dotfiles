-- Invoked with -u NONE: never load user/plugin init hooks, Mason installers or
-- build hooks while applying pins. Missing plugins require separate review.
local temporary_lock
local function restore()
  local root = assert(vim.env.DOTFILES_UPDATE_ROOT, "DOTFILES_UPDATE_ROOT is required")
  local lock_path = root .. "/nvim/lua/plugins/lazy-lock.json"
  local lock_lines = vim.fn.readfile(lock_path)
  local lock = vim.json.decode(table.concat(lock_lines, "\n"))
  assert(type(lock) == "table" and next(lock), "lazy-lock.json must contain pins")

  local plugin_root = vim.fn.stdpath("data") .. "/lazy"
  local lazy_path = plugin_root .. "/lazy.nvim"
  assert(vim.fn.isdirectory(lazy_path .. "/.git") == 1, "lazy.nvim is missing; bootstrap a reviewed commit first")
  assert(lock["lazy.nvim"], "lazy.nvim itself must be pinned in lazy-lock.json")

  local function git(dir, ...)
    local args = { "git", "-C", dir }
    vim.list_extend(args, { ... })
    local result = vim.fn.system(args)
    assert(vim.v.shell_error == 0, "git failed in " .. dir .. ": " .. result)
    return vim.trim(result)
  end

  local specs, installed = {}, {}
  for name, pin in pairs(lock) do
    assert(type(name) == "string" and name:match("^[%w_.-]+$") and name ~= "." and name ~= "..", "invalid plugin name")
    assert(type(pin) == "table" and type(pin.commit) == "string"
      and #pin.commit == 40 and pin.commit:match("^[0-9a-f]+$"), "invalid commit pin: " .. name)
    local dir = plugin_root .. "/" .. name
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      local url = git(dir, "remote", "get-url", "origin")
      assert(url ~= "", "missing origin: " .. name)
      specs[#specs + 1] = { name = name, url = url, commit = pin.commit, lazy = true, build = false }
      installed[name] = pin.commit
    else
      print("Held (not installed): " .. name)
    end
  end

  -- Lazy rewrites its lockfile even on restore. Keep the reviewed source intact,
  -- including entries for plugins that are not installed on this machine.
  temporary_lock = vim.fn.tempname()
  assert(vim.fn.writefile(lock_lines, temporary_lock) == 0, "cannot create temporary lockfile")
  -- -u NONE disables loadplugins, but Lazy.setup needs it enabled. Restrict the
  -- runtimepath first so its startup cannot source the user's plugin directory.
  vim.opt.rtp = { vim.env.VIMRUNTIME, lazy_path }
  vim.opt.loadplugins = true
  local lazy = require("lazy")
  lazy.setup(specs, {
    root = plugin_root,
    lockfile = temporary_lock,
    defaults = { lazy = true },
    install = { missing = false },
    pkg = { enabled = false },
    rocks = { enabled = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
    readme = { enabled = false, root = temporary_lock .. "-readme" },
    performance = { rtp = { reset = false } },
  })
  lazy.restore({ wait = true, show = false })

  local plugins = require("lazy.core.config").plugins
  for name, commit in pairs(installed) do
    local plugin = assert(plugins[name], "plugin missing from Lazy: " .. name)
    for _, task in ipairs(plugin._.tasks or {}) do
      assert(not task:has_errors(), "Lazy task failed: " .. name)
    end
    assert(git(plugin_root .. "/" .. name, "rev-parse", "HEAD") == commit, "commit mismatch after restore: " .. name)
  end
  print("Restored installed plugin commits; build hooks were held for separate review.")
end

local ok, err = xpcall(restore, debug.traceback)
if temporary_lock then
  vim.fn.delete(temporary_lock)
end
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
