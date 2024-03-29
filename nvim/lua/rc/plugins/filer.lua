---@type LazySpec
local spec = {
  {
    'stevearc/oil.nvim',
    keys = {
      {
        "<leader>e",
        function()
          vim.cmd.Oil()
        end,
      },
    },
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "lambdalisue/fern.vim",
    dependencies = {
      -- filer with fonts
      -- require https://github.com/ryanoasis/nerd-fonts
      -- brew tap homebrew/cask-fonts
      -- brew install --cask font-hack-nerd-font
      "lambdalisue/nerdfont.vim",
      "lambdalisue/fern-renderer-nerdfont.vim",
      -- filer icon with color
      "lambdalisue/glyph-palette.vim",
      "nvim-tree/nvim-web-devicons", -- File icons
    },
    cmd = "Fern",
    keys = {
      { "<C-n>", ":Fern . -reveal=% -drawer -toggle -width=40<CR>", desc = "toggle fern" },
    },
    init = function()
      vim.g["fern#renderer"] = "nerdfont"
      vim.cmd([[
       augroup my-glyph-palette
         autocmd! *
         autocmd FileType fern call glyph_palette#apply()
         autocmd FileType nerdtree,startify call glyph_palette#apply()
       augroup END
      ]])
      -- fern
      vim.cmd([[
        let hide_dirs  = '^\%(\.git\|node_modules\|dist\)$'  " here you write the dir names
        let hide_files = '\%(\.byebug\|\.ruby-\)\+'    " here you write the file names
        let g:fern#default_exclude = hide_dirs . '\|' . hide_files  " here you exclude them
        let g:fern#default_hidden=1
      ]])
    end,
  },
}

return spec
