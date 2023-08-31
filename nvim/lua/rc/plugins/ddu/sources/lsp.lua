local helper = require("helpers.ddu")

---@type LazySpec
local spec = {
  "uga-rosa/ddu-source-lsp",
  dependencies = { "ddu.vim", "ddu-kind-file" },
  config = function()
    helper.patch_global({
      kindOptions = {
        lsp = {
          defaultAction = "open",
        },
        lsp_codeAction = {
          defaultAction = "apply",
        },
      }
    })

    helper.setup("lsp:symbol", {
      sources = {
        { name = "lsp_workspaceSymbol" },
      },
      sourceOptions = {
        _ = {
          converters = { "converter_lsp_symbol" },
        },
        lsp = { volatile = true },
      },
    })

    helper.setup("lsp-definition", {
        sources = {
          { name = "lsp_definition", params = { method = "textDocument/definition" } },
          { name = "lsp_definition", params = { method = "textDocument/typeDefinition" } },
          { name = "lsp_definition", params = { method = "textDocument/declaration" } },
          { name = "lsp_definition", params = { method = "textDocument/implementation" } },
        },
        sync = true,
        uiParams = {
          ff = {
            immediateAction = "open",
          },
        },
      },
      "<leader>gd"
    )

    helper.setup("lsp-references", {
        sources = { { name = "lsp_references" } },
      },
      "<leader>gr"
    )

    helper.setup("lsp-symbols", {
        sources = { { name = "lsp_workspaceSymbol" } },
        sourceOptions = { lsp = { volatile = true } },
      },
      "<leader>gw"
    )

    helper.setup("lsp-call-hierarchy", {
        sources = {
          {
            name = "lsp_callHierarchy", params = { method = "callHierarchy/incomingCalls", }
          },
          {
            name = "lsp_callHierarchy", params = { method = "callHierarchy/outgoingCalls", }
          }
        },
        sourceOptions = { lsp = { volatile = true } },
        uiParams = {
          ff = {
            displayTree = true,
            startFilter = false,
          },
        },
      },
      "<leader>gh"
    )
  end,
}
return spec
