local keymap = vim.keymap

keymap.set('n', 'x', '"_x')

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- New tab
keymap.set('n', 'te', ':tabedit<CR>')
-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')
-- Move window
keymap.set('n', '<Space>', '<C-w>w')
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sl', '<C-w>l')

-- Resize window
keymap.set('n', '<C-w><left>', '<C-w><')
keymap.set('n', '<C-w><right>', '<C-w>>')
keymap.set('n', '<C-w><up>', '<C-w>+')
keymap.set('n', '<C-w><down>', '<C-w>-')
--

-- fern mapping
keymap.set("n", "<C-n>", ":Fern . -reveal=% -drawer -toggle -width=40<CR>")
--fern reload mapping
-- vim.cmd([[
-- function s:init_fern_mapping_reload_all()
--     nmap <buffer> L <Plug>(fern-action-reload:all)
-- endfunction
-- augroup my-fern-mapping-reload-all
--     autocmd! *
--     autocmd FileType fern call s:init_fern_mapping_reload_all()
-- augroup END
-- ]])

-- fern nerdfont
vim.g['fern#renderer'] = 'nerdfont'

-- fern icon colorize
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



-- telescope
-- local builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<space>ff', builtin.find_files, {})
-- vim.keymap.set('n', '<space>fg', builtin.live_grep, {}) -- require https://github.com/BurntSushi/ripgrep
-- vim.keymap.set('n', '<space>fb', builtin.buffers, {})
-- vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
-- vim.keymap.set('n', '<space>gf', builtin.git_files, {})
-- vim.keymap.set('n', '<space>gs', builtin.git_status, {})
-- vim.keymap.set('n', '<space>gc', builtin.git_commits, {})
-- vim.keymap.set('n', '<space>gb', builtin.git_branches, {})


-- coc
-- map("n", "<space>a",  ":<C-u>CocList diagnostics<cr>")
-- map("n", "<space>e",  ":<C-u>CocList extensions<cr>")
-- map("n", "<space>c",  ":<C-u>CocList commands<cr>")
-- map("n", "<space>o",  ":<C-u>CocList outline<cr>")
-- map("n", "<space>s",  ":<C-u>CocList -I symbols<cr>")
-- map("n", "<space>j",  ":<C-u>CocNext<CR>")
-- map("n", "<space>k",  ":<C-u>CocPrev<CR>")
-- map("n", "<space>p",  ":<C-u>CocListResume<CR>")
--
-- vim.cmd([[
-- nmap <silent> <space>cd <Plug>(coc-definition)
-- nmap <silent> <space>ct <Plug>(coc-type-definition)
-- nmap <silent> <space>ci <Plug>(coc-implementation)
-- nmap <silent> <space>cr <Plug>(coc-references)
-- nmap <silent> <space>cn <Plug>(coc-rename)
-- ]])

-- toggleterm
-- See https://github.com/akinsho/toggleterm.nvim
-- function _G.set_terminal_keymaps()
--   local opts = {buffer = 0}
--   vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
--   vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
--   vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
--   vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
--   vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
--   vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
-- end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
-- vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
