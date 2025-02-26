local _, util = pcall(require, "lspconfig/util")
local config = {
  root_dir = util.root_pattern("deno.json"),
  init_options = {
    lint = true,
    unstable = true,
    suggest = {
      imports = {
        hosts = {
          ["https://deno.land"] = true,
          ["https://cdn.nest.land"] = true,
          ["https://crux.land"] = true,
        },
      },
    },
  },
}

return {
  config = function(_)
    return config
  end,
}
