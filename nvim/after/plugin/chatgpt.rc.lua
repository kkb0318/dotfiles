local status, chatgpt = pcall(require, "chatgpt")
if (not status) then return end

chatgpt.setup({})

vim.keymap.set('n', '<Leader>g', '<cmd>ChatGPT<cr>', { silent = true })
vim.keymap.set('n', '<Leader>e', '<cmd>ChatGPTEditWithInstructions<cr>', { silent = true })
