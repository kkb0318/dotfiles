local status, util = pcall(require, "lspconfig/util")
if (not status) then return end

local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({ '*', '.*' }) do
    local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fnexepath('python') or 'python'
end

local config = {
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path(config.root_dir)
  end
}

return {
  config = function(_)
    return config
  end,
}
