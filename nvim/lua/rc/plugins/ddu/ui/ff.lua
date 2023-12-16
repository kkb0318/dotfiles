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
          autoAction = { name = "preview", delay = 1 },
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
          highlights = {
            filterText = "dduFilter",
            floating = "Normal",
            floatingCursorLine = "dduCursorLine",
            floatingBorder = "dduBorder",
            prompt = "dduPrompt",
          },
          ignoreEmpty = true,
        },
      },
    })
    local function resize()
      local lines = vim.opt.lines:get()
      local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
      local columns = vim.opt.columns:get()
      local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)
      local previewWidth = math.floor(width / 2)

      helper.patch_global({
        uiParams = {
          ff = {
            winHeight = height,
            winRow = row,
            winWidth = width,
            winCol = col,
            previewHeight = height,
            previewRow = row,
            previewWidth = previewWidth,
            previewCol = col + (width - previewWidth),
          },
        },
      })
    end
    resize()

    vim.api.nvim_create_autocmd("VimResized", {
      callback = resize,
    })


    local nmap = function(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { nowait = true, buffer = true, silent = true, remap = false })
    end
    local group = vim.api.nvim_create_augroup("ddu-ui-ff", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "ddu-ff",
      callback = function()
        nmap("i", helper.action("openFilterWindow"))
        nmap("<esc>", helper.action("quit"))
        nmap("<cr>", helper.action("itemAction"))
        nmap("l", helper.action("expandItem"))
        nmap("h", helper.action("collapseItem"))
        nmap("+", helper.action("chooseAction"))
        nmap("<C-q>", function()
          vim.fn["ddu#ui#do_action"]("toggleAllItems")
          vim.fn["ddu#ui#do_action"]("itemAction", { name = "quickfix" })
        end)
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
