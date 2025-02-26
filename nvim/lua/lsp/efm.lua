local actionlint = {
  prefix = "actionlint",
  lintSource = "efm/actionlint",
  lintCommand = 'actionlint -no-color -oneline -stdin-filename "${INPUT}" -',
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %.%#: SC%n:%trror:%m", "%f:%l:%c: %.%#: SC%n:%tarning:%m", "%f:%l:%c: %.%#: SC%n:%tnfo:%m", "%f:%l:%c: %m" },
  requireMarker = true,
  rootMarkers = { ".github/workflows" },
}

local markdownlint = {
  prefix = "markdownlint",
  lintSource = "efm/markdownlint",
  lintCommand = "markdownlint --stdin",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = { "%f:%l:%c %m", "%f:%l %m", "%f: %l: %m" },
}

local textlint = {
  prefix = "textlint",
  lintSource = "efm/textlint",
  lintCommand = "textlint --no-color --format compact --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = { "%.%#: line %l, col %c, %trror - %m", "%.%#: line %l, col %c, %tarning - %m" },
  rootMarkers = { ".textlintrc", ".textlintrc.js", ".textlintrc.json", ".textlintrc.yml", ".textlintrc.yaml" },
}

local config = {
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
    codeAction = true,
  },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      yaml = { actionlint },
      markdown = { textlint, markdownlint },
    },
  },

}

return {
  config = function(_)
    return config
  end,
}
