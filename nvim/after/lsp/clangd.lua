local config = {
  settings = {
    offset_encoding = 'utf-16'
  }
}

return {
  config = function(_)
    return config
  end,
}
