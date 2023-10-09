local g = vim.g
local o = vim.o


-- tab
o.softtabstop = 2

g.mapleader = ' '

vim.cmd("autocmd!")

vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

vim.wo.number = true

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.shell = 'fish'
vim.opt.backupskip = { '/tmp/*', '/private/tmp/*' }
vim.opt.inccommand = 'split'
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false         -- No Wrap lines
vim.opt.backspace = { 'start', 'eol', 'indent' }
vim.opt.path:append { '**' } -- Finding files - Search down into subfolders
vim.opt.wildignore:append { '*/node_modules/*' }


-- lang
vim.opt.helplang = { "en", "ja" }

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = '*',
  command = "set nopaste"
})

-- Add asterisks in block comments
vim.opt.formatoptions:append { 'r' }

-- ignore (:w, :q, ..) commandline history
vim.api.nvim_exec([[
  augroup histclean
    autocmd!
    autocmd ModeChanged c:* lua HistClean()
  augroup END
]], false)

function HistClean()
  local cmd = vim.fn.histget(":", -1)
  if cmd == "x" or cmd == "xa" or cmd:match("^w?q?a?!?$") then
    vim.fn.histdel(":", -1)
  end
end
