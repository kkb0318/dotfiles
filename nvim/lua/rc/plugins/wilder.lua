---@type LazySpec
local spec = {
  {
    "gelguy/wilder.nvim",
    event = "VeryLazy",
    config = function()
      local wilder = require('wilder')
      wilder.setup({ modes = { ':', '/', '?' } })

      wilder.set_option('pipeline', {
        wilder.branch(
          wilder.cmdline_pipeline(),
          wilder.search_pipeline()
        ),
      })

      wilder.set_option('renderer', wilder.wildmenu_renderer({
        highlighter = wilder.basic_highlighter(),
        separator = ' · ',
        left = { ' ', wilder.wildmenu_spinner(), ' ' },
        right = { ' ', wilder.wildmenu_index() },
      }))
      wilder.set_option('renderer', wilder.popupmenu_renderer({
        -- highlighter applies highlighting to the candidates
        highlighter = wilder.basic_highlighter(),
      }))
    end,
  },
}

return spec
