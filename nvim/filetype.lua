-- Filetype detection
--

-- Enable neovim runtime filetype.lua
vim.g.do_filetype_lua = 1

-- Define the mappings in a table
local mappings = {
  -- Filename mappings
  {
    filename = {
      Brewfile = 'ruby',
      justfile = 'just',
      Justfile = 'just',
      Tmuxfile = 'tmux',
      ['go.sum'] = 'go',
      ['yarn.lock'] = 'yaml',
      ['.buckconfig'] = 'toml',
      ['.flowconfig'] = 'ini',
      ['.tern-project'] = 'json',
      ['.jsbeautifyrc'] = 'json',
      ['.jscsrc'] = 'json',
      ['.watchmanconfig'] = 'json',
    },
  },
  -- Pattern mappings
  {
    pattern = {
      ['.*%.js%.map'] = 'json',
      ['.*%.postman_collection'] = 'json',
      ['Jenkinsfile.*'] = 'groovy',
      ['%.kube/config'] = 'yaml',
      ['%.config/git/users/.*'] = 'gitconfig',
      ['.*/playbooks/.*%.yaml'] = 'yaml.ansible',
      ['.*/playbooks/.*%.yml'] = 'yaml.ansible',
      ['.*/roles/.*%.yaml'] = 'yaml.ansible',
      ['.*/roles/.*%.yml'] = 'yaml.ansible',
      ['.*/inventory/.*%.ini'] = 'ansible_hosts',
    },
  },
}

for _, mapping in ipairs(mappings) do
  vim.filetype.add(mapping)
end
