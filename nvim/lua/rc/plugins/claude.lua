---@type LazySpec
local spec = {
  {
    "coder/claudecode.nvim",
    config = true,
    keys = {
      { ";c",  nil,                              desc = "AI/Claude Code" },
      { ";cc", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { ";cf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { ";cr", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { ";cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { ";cs", "<cmd>ClaudeCodeSend<cr>",        mode = "v",              desc = "Send to Claude" },
      {
        ";cs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { ";ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { ";cd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  }
}
return spec
