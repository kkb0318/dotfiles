---@type LazySpec
local spec = {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  event = "VeryLazy",
  build = ":TSUpdate",
  config = function()
    ---@diagnostic disable-next-line
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
        disable = { "vimdoc" },
      },
      indent = {
        enable = true,
        disable = {},
      },
      ensure_installed = {
        "css",
        "cpp",
        "fish",
        "go",
        "html",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "rst",
        "rust",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "yaml",
      },
    })
    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
    parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
  end,
}

return spec
