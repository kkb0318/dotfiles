local M = {}

---@param dict table
function M.patch_global(dict)
  vim.fn["ddu#custom#patch_global"](dict)
end


---@param name string
---@param params? table
---@return function
function M.action(name, params)
  return function()
      vim.fn["ddu#ui#do_action"](name, params or vim.empty_dict())
  end
end

---@param name string
---@param params? table
---@return function
function M.item_action(name, params)
  return M.action("itemAction", { name = name, params = params })
end

---@param name string A name of the local option.
---@param dict table<string, any> ddu options.
---@param startkey string 
function M.setup(name, dict, startkey)
  vim.fn["ddu#custom#patch_local"](name, dict)
  vim.keymap.set("n", startkey, function()
    vim.fn["ddu#start"]({ name = name })
  end, { remap = false, desc = "Start ddu: " .. name })
end
return M
