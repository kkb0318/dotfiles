local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "yuki-yano/ai-review.vim",
  dependencies = { "ddu.vim" },
  config = function()
    helper.patch_global({
      kindOptions = {
        ["ai-review-request"] = {
          defaultAction = "open",
        },
        ["ai-review-log"] = {
          defaultAction = "resume",
        },
      }
    })
    vim.fn["ai_review#config"]({ chat_gpt = { model = "gpt-3.5-turbo" } })
  end,
}

return spec
