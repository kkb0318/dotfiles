--vim.lsp.set_log_level("debug")

local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then return end

local protocol = require('vim.lsp.protocol')

local augroup_format = vim.api.nvim_create_augroup("Format", { clear = true })

local enable_format_on_save = function(_, bufnr)
  vim.api.nvim_clear_autocmds({ group = augroup_format, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup_format,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ bufnr = bufnr })
    end,
  })
end


-- TODO: deprecated
-- local enable_format_on_save_go = function(_, bufnr)
--   vim.api.nvim_clear_autocmds({ group = augroup_format, buffer = bufnr })
--   vim.api.nvim_create_autocmd("BufWritePre", {
--     group = augroup_format,
--     pattern = '*.go',
--     callback = function()
--       vim.lsp.buf.format({ bufnr = bufnr })
--       vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
--     end,
--   })
-- end


-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  --local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  --buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- vim0illuminate
  require("illuminate").on_attach(client)

  -- Short-circuit for Helm template files
  -- if vim.bo[bufnr].buftype ~= '' or vim.bo[bufnr].filetype == 'helm' then
  --   require('user').diagnostic.remove(bufnr)
  --   return
  -- end

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', ',s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', ',wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', ',wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', ',wl', '<cmd>lua =vim.lsp.buf.list_workspace_folders()<CR>', opts)
  buf_set_keymap('n', 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('x', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', '<Leader>ce', '<cmd>lua vim.diagnostic.open_float({source=true})<CR>', opts)
end

protocol.CompletionItemKind = {
  '', -- Text
  '', -- Method
  '', -- Function
  '', -- Constructor
  '', -- Field
  '', -- Variable
  '', -- Class
  'ﰮ', -- Interface
  '', -- Module
  '', -- Property
  '', -- Unit
  '', -- Value
  '', -- Enum
  '', -- Keyword
  '﬌', -- Snippet
  '', -- Color
  '', -- File
  '', -- Reference
  '', -- Folder
  '', -- EnumMember
  '', -- Constant
  '', -- Struct
  '', -- Event
  'ﬦ', -- Operator
  '', -- TypeParameter
}

-- Set up completion using nvim_cmp with LSP source
local capabilities = require('cmp_nvim_lsp').default_capabilities()


local function make_config(server_name)
  -- Setup base config for each server.
  local c = {}

  -- TODO: deprecated
  -- if server_name == "gopls" then
  --   c.on_attach = function(client, bufnr)
  --     on_attach(client, bufnr)
  --     enable_format_on_save_go(client, bufnr)
  --   end
  -- else
  --   c.on_attach = function(client, bufnr)
  --     on_attach(client, bufnr)
  --     enable_format_on_save(client, bufnr)
  --   end
  -- end

  c.on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    enable_format_on_save(client, bufnr)
  end
  c.capabilities = capabilities

  -- Merge user-defined lsp settings.
  -- These can be overridden locally by lua/lsp-local/<server_name>.lua
  local exists, module = pcall(require, 'lsp-local.' .. server_name)
  if not exists then
    exists, module = pcall(require, 'lsp.' .. server_name)
  end
  if exists then
    local user_config = module.config(c)
    for k, v in pairs(user_config) do
      c[k] = v
    end
  end

  return c
end

require('mason').setup()
local mason_lspconfig = require('mason-lspconfig')
mason_lspconfig.setup()
local packages = mason_lspconfig.get_installed_servers()

-- Setup language servers using nvim-lspconfig
for _, ls in pairs(packages) do
  local opts = make_config(ls)
  nvim_lsp[ls].setup(opts)
  -- print(ls) -- check run :source
end

-- local handlers = {
--   definition = vim.lsp.handlers["textDocument/definition"],
-- }

-- -- `textDocument/definition` メッセージハンドラ。LSPサーバから定義の位置情報が返されたときに呼び出される。
-- vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
--   if err then
--     vim.notify(err, vim.log.levels.ERROR)
--     return
--   end
--   if not result then
--     return
--   end
--   -- result type is `Location | Location[] | LocationLink[]`
--   if #result == 1 or result.uri then
--     -- single location
--     -- handlers.definition(err, result, ctx, config)
--     require("rc.ddu").start({
--       {
--         name = "lsp_definitions",
--         params = {
--           locations = result,
--         },
--       },
--     })
--   else
--     -- 複数の位置が得られた場合、`ddu` を使ってそれらを表示・選択できるようにする。
--     require("rc.ddu").start({
--       {
--         name = "lsp_definitions",
--         params = {
--           locations = result,
--         },
--       },
--     })
--   end
-- end


vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 4, prefix = "●" },
    severity_sort = true,
  }
)

-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = {
    prefix = '●'
  },
  update_in_insert = true,
  float = {
    source = "always", -- Or "if_many"
  },
})
