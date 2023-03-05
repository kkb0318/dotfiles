local status, api = pcall(require, "Comment.api")
if (not status) then return end

vim.keymap.set(
  "n", "gc", api.call("toggle.linewise", "g@"),
  { expr = true }
)

vim.keymap.set(
  "n", "gcc", api.call("toggle.linewise.current", "g@$"),
  { expr = true }
)
