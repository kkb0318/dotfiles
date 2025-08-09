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

-- New tab
keymap.set('n', 'tn', ':tabnew<CR>')

-- terminal mode
keymap.set('t', '<esc>', '<C-\\><C-N>', { silent = true })
keymap.set('t', '<C-w>h', '<C-\\><C-N><C-w>h', { silent = true })
keymap.set('t', '<C-w>j', '<C-\\><C-N><C-w>j', { silent = true })
keymap.set('t', '<C-w>k', '<C-\\><C-N><C-w>k', { silent = true })
keymap.set('t', '<C-w>l', '<C-\\><C-N><C-w>l', { silent = true })





-- Move current page to New tab
keymap.set("n", "tm", [[<Cmd>lua MoveToNewTab()<CR>]], { silent = true })

-- Camel to snake_case
keymap.set("n", "<leader>cs", [[<Cmd>lua CamelToSnake()<CR>]], { silent = true })

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

function CamelToSnake()
  -- カーソル位置の単語を取得
  local word = vim.fn.expand("<cword>")

  local new_word = CamelToSnakeString(word)
  local cmd = "s/\\<" .. word .. "\\>/" .. new_word .. "/g"
  vim.api.nvim_command(cmd)
end

function CamelToSnakeString(str)
  return str:gsub('(%a)(%u)', function(a, b) return a:lower() .. '_' .. b:lower() end)
end

--- clipboard ---
-- コマンドラインのカーソル位置にテキストを挿入
---@param text string 挿入するテキスト
local function insert_at_cmdline_cursor(text)
  local cmdline = vim.fn.getcmdline()
  local cursor_pos = vim.fn.getcmdpos()

  -- 安全性チェック
  if not cmdline or not cursor_pos or cursor_pos <= 0 then
    vim.fn.setcmdline(text, #text + 1)
    return
  end

  -- カーソル位置で分割
  local before_cursor = cmdline:sub(1, cursor_pos - 1)
  local after_cursor = cmdline:sub(cursor_pos)

  -- テキストを挿入してカーソル位置を更新
  local new_cmdline = before_cursor .. text .. after_cursor
  local new_cursor_pos = cursor_pos + #text

  vim.fn.setcmdline(new_cmdline, new_cursor_pos)
end

-- ファイルパス展開のヘルパー関数
local function create_path_inserter(expand_pattern)
  return function()
    local expanded_path = vim.fn.expand(expand_pattern)
    insert_at_cmdline_cursor(expanded_path)
  end
end

local function create_path_copier(expand_pattern)
  return function()
    local expanded_path = vim.fn.expand(expand_pattern)
    vim.fn.setreg('+', expanded_path) -- システムクリップボードにコピー
    vim.fn.setreg('"', expanded_path) -- デフォルトレジスタにもコピー
    print("クリップボードにコピー: " .. expanded_path)
  end
end

-- パスタイプの定義
local path_mappings = {
  { key = "<C-y>t", pattern = "%:t", desc = "ファイル名のみ" },
  { key = "<C-y>p", pattern = "%:p", desc = "絶対パス" },
  { key = "<C-y>r", pattern = "%", desc = "相対パス" },
  { key = "<C-y>h", pattern = "%:h", desc = "相対ディレクトリ" },
  { key = "<C-y>H", pattern = "%:p:h", desc = "絶対ディレクトリ" },
}

-- キーマッピングの設定
for _, mapping in ipairs(path_mappings) do
  vim.keymap.set("c", mapping.key, create_path_inserter(mapping.pattern), {
    desc = "コマンドラインに挿入: " .. mapping.desc
  })
  vim.keymap.set("n", mapping.key, create_path_copier(mapping.pattern), {
    desc = mapping.desc
  })
end
