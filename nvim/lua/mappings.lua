local keymap = vim.keymap

keymap.set('n', 'x', '"_x')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})


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

-- no highlight
keymap.set("n", "<Esc><Esc>", "<Cmd>nohl<CR>")


-- New tab
keymap.set('n', 'tn', ':tabnew<CR>')



-- Move current page to New tab
keymap.set("n", "tm", [[<Cmd>lua MoveToNewTab()<CR>]], { silent = true })

function MoveToNewTab()
  -- Equivalent to :tab split
  vim.cmd("tab split")
  -- Equivalent to :tabprevious
  vim.cmd("tabprevious")
  -- Get window count in the current tab page
  local win_count = vim.fn.winnr('$')
  -- Get buffer count
  local buf_count = vim.fn.bufnr('$')
  -- Equivalent to Vimscript's if-elseif-endif logic
  if win_count > 1 then
    -- Equivalent to :close
    vim.cmd("close")
  elseif buf_count > 1 then
    -- Equivalent to :buffer #
    vim.cmd("buffer #")
  end
  -- Equivalent to :tabnext
  vim.cmd("tabnext")
end
