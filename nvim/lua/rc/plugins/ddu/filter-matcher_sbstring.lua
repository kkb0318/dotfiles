---@type LazySpec
local spec = {
  "Shougo/ddu-filter-matcher_substring",
  dependencies = "ddu.vim",
  config = function()
    vim.fn["ddu#custom#patch_global"]({
      sourceOptions = {
        ["_"] = {
          matchers = { "matcher_substring" }
        }
      }
    })
  end,
}

return spec
