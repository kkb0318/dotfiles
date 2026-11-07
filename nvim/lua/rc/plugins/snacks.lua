---@type LazySpec
local spec = {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
    },
    keys = {
      { ";a", function() Snacks.picker.files() end, desc = "Find Files" },
      { ";f", function() Snacks.picker.files() end, desc = "Find Files" },
      { ";r", function() Snacks.picker.grep() end, desc = "Grep" },
      { ";h", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "q:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "q/", function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gd", function() Snacks.picker.lsp_definitions() end, desc = "LSP Definitions" },
      { "<leader>gr", function() Snacks.picker.lsp_references() end, desc = "LSP References" },
      { "<leader>gw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      { "<leader>gh", function() Snacks.picker.lsp_incoming_calls() end, desc = "LSP Incoming Calls" },
    },
  },
}

return spec
