local function has(name)
  return vim.fn.has(name) == 1
end

if has "macunix" then
  vim.opt.clipboard:append { 'unnamedplus' }
end
if has "win32" then
  vim.opt.clipboard:prepend { 'unnamed', 'unnamedplus' }
end
if has "wsl" then
  vim.cmd [[
    augroup Yank
    autocmd!
    autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
    augroup END
  ]]
end
