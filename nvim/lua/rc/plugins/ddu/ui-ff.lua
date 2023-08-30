local helper = require("helpers.ddu")


---@type LazySpec
local spec = {
  "Shougo/ddu-ui-ff",
  dependencies = "ddu.vim",
  config = function()
    helper.patch_global({
      ui = "ff",
      uiParams = {
        ff = {
          startFilter = true,
          prompt = "> ",
          split = "floating",
          floatingBorder = "single",
          filterFloatingPosition = "top",
          autoAction = {
            name = "preview",
          },
          startAutoAction = true,
          previewFloating = true,
          previewFloatingBorder = "single",
          previewSplit = "vertical",
          previewWindowOptions = {
            { "&signcolumn", "no" },
            { "&foldcolumn", 0 },
            { "&foldenable", 0 },
            { "&number",     0 },
            { "&wrap",       0 },
            { "&scrolloff",  0 },
          },
          ignoreEmpty = true,
        },
      },
    })

    local nmap = function(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { nowait = true, buffer = true, silent = true, remap = false })
    end
    local group = vim.api.nvim_create_augroup("ddu-ui-ff", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "ddu-ff",
      callback = function()
        nmap("/", helper.action("openFilterWindow"))
        nmap("<esc>", helper.action("quit"))
        nmap("<cr>", helper.action("itemAction"))
        nmap("l", helper.action("expandItem"))
        nmap("h", helper.action("collapseItem"))
        nmap("+", helper.action("chooseAction"))
      end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "ddu-ff-filter",
      callback = function()
        vim.opt_local.cursorline = false
        local imap = function(lh, rh, opt)
          local option = vim.tbl_extend("keep", opt or {}, { nowait = true, buffer = true, silent = true, remap = false })
          vim.keymap.set("i", lh, rh, option)
        end
        imap("<esc>", "<esc>dd<cmd>call ddu#ui#do_action('closeFilterWindow')<cr>")
        imap("<cr>", "<esc><cmd>call ddu#ui#do_action('leaveFilterWindow')<cr>")
        imap("<C-A>", "<Home>")
        imap("<C-F>", "<Right>")
        imap("<C-B>", "<Left>")
        imap("<C-D>", "<Del>")
        imap("<C-H>", "<BS>", { remap = true })
      end,
    })
  end,
}

return spec
