local status, ts = pcall(require, "nvim-treesitter.configs")
if (not status) then return end

ts.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    "fish",
    "css",
    "html",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "rst",
    "terraform",
    "toml",
    "tsx",
    "typescript",
    "yaml",
  },
  autotag = {
    enable = true,
  },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
