local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end


vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'


  -- surround
  -- use({
  --   'kylechui/nvim-surround',
  --   tag = "*",
  --   config = function()
  --     require("nvim-surround").setup({
  --     })
  --   end
  -- })

  -- lsp (like VS Code)
  -- use {'neoclide/coc.nvim', branch = 'release'}
  use 'onsails/lspkind-nvim'  -- vscode-like pictograms
  use 'nvim-lua/plenary.nvim' -- lua common utilities
  -- use 'hrsh7th/nvim-cmp'                  -- Completion
  -- use 'hrsh7th/cmp-buffer'                -- nvim-cmp source for buffer words
  -- use 'hrsh7th/cmp-nvim-lsp'              -- nvim-cmp source for neovim's built-in LSP (A completion engine plugin for neovim )
  use 'neovim/nvim-lspconfig'             -- LSP (nvim official)
  use 'jose-elias-alvarez/null-ls.nvim'   -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
  use 'williamboman/mason.nvim'           -- installer for LSP. formatter, linster
  use 'williamboman/mason-lspconfig.nvim' -- closes some gaps that exist between mason.nvim and lspconfig
  -- snippet with nvim-cmp
  use 'L3MON4D3/LuaSnip'

  -- lsp UI
  use 'glepnir/lspsaga.nvim' -- LSP UI
  -- use {
  --   "j-hui/fidget.nvim",
  --   tag = "legacy",
  --   event = "VimEnter",
  -- }

  ---- theme
  ---- use {
  ----   'projekt0n/github-nvim-theme',
  ----   tag = 'v0.0.7'
  ---- }
  -- use { "bluz71/vim-nightfly-colors", as = "nightfly" }
  ---- use { "bluz71/vim-moonfly-colors", as = "moonfly" }


  ---- comment out
  -- use {
  --   "numToStr/Comment.nvim",
  --   config = function()
  --     require("Comment").setup()
  --   end
  -- }
  ---- todo comment highlight
  -- use {
  --   "folke/todo-comments.nvim",
  --   requires = "nvim-lua/plenary.nvim"
  -- }

  -- helm highlight
  -- use 'towolf/vim-helm'

  -- completion
  -- use {
  --   'gelguy/wilder.nvim',
  --   config = function()
  --     -- config goes here
  --   end,
  -- }

  -- use {'antoinemadec/coc-fzf', branch = 'release'}
  -- use {
  --   'neovim/nvim-lspconfig'
  -- }

  -- motion
  -- use {'haya14busa/vim-edgemotion'}
  --

  -- ddu
  -- use 'vim-denops/denops.vim'
  -- use 'Shougo/ddu.vim'
  -- use 'Shougo/ddu-ui-filer'
  -- use 'Shougo/ddu-source-file'
  -- use 'Shougo/ddu-kind-file'
  -- use 'Shougo/ddu-column-filename'

  ---- doc generator
  -- use 'danymat/neogen'

  -- filer
  -- use 'lambdalisue/fern.vim'
  ---- use 'lambdalisue/fern-git-status.vim'
  ---- use { 'LumaKernel/fern-mapping-reload-all.vim', requires = { 'lambdalisue/fern.vim' } }

  -- highlight
  -- use({
  --   'nvim-treesitter/nvim-treesitter',
  --   run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  -- })
  -- highlight other use
  -- use { "RRethy/vim-illuminate" }

  -- search
  -- use { "kevinhwang91/nvim-hlslens" }


  -- marking
  -- use "chentoast/marks.nvim"

  -- auto tag
  -- use { "windwp/nvim-autopairs" }
  -- use { "windwp/nvim-ts-autotag" }
  -- bracket
  -- use { "hrsh7th/nvim-insx" }

  -- filer with fonts
  -- require https://github.com/ryanoasis/nerd-fonts
  -- brew tap homebrew/cask-fonts
  -- brew install --cask font-hack-nerd-font
  -- use 'lambdalisue/nerdfont.vim'
  -- use 'lambdalisue/fern-renderer-nerdfont.vim'
  -- -- filer icon with color
  -- use 'lambdalisue/glyph-palette.vim'
  -- use 'kyazdani42/nvim-web-devicons' -- File icons


  -- window
  -- use {
  --   "akinsho/toggleterm.nvim",
  --   tag = '*'
  -- }

  -- status bar
  -- use {
  --   'nvim-lualine/lualine.nvim',
  --   requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  -- }
  ---- use 'akinsho/nvim-bufferline.lua'


  -- fuzzy finder
  -- use {
  --   "nvim-telescope/telescope.nvim", tag = '0.1.1',
  -- }
  -- use { "nvim-telescope/telescope-file-browser.nvim" }

  -- git
  -- use { 'tpope/vim-fugitive' }
  -- use 'lewis6991/gitsigns.nvim'
  -- use 'dinhhuy258/git.nvim' -- simplie Clone of vim-fugitive

  -- zen mode
  -- use 'folke/zen-mode.nvim'


  -- markdown
  -- use({
  --   "iamcco/markdown-preview.nvim",
  --   run = "cd app && npm install",
  --   setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
  --   ft = { "markdown" },
  -- })
  -- use "mattn/vim-maketable"

  -- increment
  -- use "monaqa/dial.nvim"

  -- plant uml
  -- use({ "aklt/plantuml-syntax" })

  -- AI
  -- use { 'zalgo3/vim-chatgpt', branch = 'nvim' }
  -- use({
  --   "jackMort/ChatGPT.nvim",
  --   requires = {
  --     "MunifTanjim/nui.nvim",
  --   }
  -- })
  -- use "github/copilot.vim"
end)



vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])
