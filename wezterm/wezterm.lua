local wezterm = require("wezterm")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["nord"]
local gpus = wezterm.gui.enumerate_gpus()
require("on")



--- load local_config
-- Write settings you don't want to make public, such as ssh_domains
package.path = os.getenv("HOME") .. "/.local/share/wezterm/?.lua;" .. package.path

---------------------------------------------------------------
--- Config
---------------------------------------------------------------
local config = {
  font = wezterm.font("Cica"),
  -- font = wezterm.font("Hack Nerd Font"),
  font_size = 16,
  -- font_size = 8.5,
  -- cell_width = 1.1,
  -- line_height = 1.1,
  -- font_rules = {
  -- 	{
  -- 		italic = true,
  -- 		font = wezterm.font("Cica", { italic = true }),
  -- 	},
  -- 	{
  -- 		italic = true,
  -- 		intensity = "Bold",
  -- 		font = wezterm.font("Cica", { weight = "Bold", italic = true }),
  -- 	},
  -- },
  check_for_updates = false,
  use_ime = true,
  -- ime_preedit_rendering = "System",
  use_dead_keys = false,
  warn_about_missing_glyphs = false,
  -- enable_kitty_graphics = false,
  animation_fps = 1,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  cursor_blink_rate = 0,
  color_scheme = "nordfox",
  color_scheme_dirs = { os.getenv("HOME") .. "/.config/wezterm/colors/" },
  adjust_window_size_when_changing_font_size = false,
  selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%",

  window_decorations = "RESIZE",
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  use_fancy_tab_bar = false,
  colors = {
    tab_bar = {
      background = scheme.background,
      new_tab = { bg_color = "#2e3440", fg_color = scheme.ansi[8], intensity = "Bold" },
      new_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.brights[8], intensity = "Bold" },
      -- format-tab-title
      -- active_tab = { bg_color = "#121212", fg_color = "#FCE8C3" },
      -- inactive_tab = { bg_color = scheme.background, fg_color = "#FCE8C3" },
      -- inactive_tab_hover = { bg_color = scheme.ansi[1], fg_color = "#FCE8C3" },
    },
  },
  exit_behavior = "CloseOnCleanExit",
  ----------------------------------------------------
  -- Tab
  ----------------------------------------------------
  tab_bar_at_bottom = false,
  show_new_tab_button_in_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  -- window settings
  window_close_confirmation = "AlwaysPrompt",
  window_background_opacity = 0.85,
  macos_window_background_blur = 20,
  disable_default_key_bindings = true,
  -- visual_bell = {
  -- 	fade_in_function = "EaseIn",
  -- 	fade_in_duration_ms = 150,
  -- 	fade_out_function = "EaseOut",
  -- 	fade_out_duration_ms = 150,
  -- },
  -- separate <Tab> <C-i>
  enable_csi_u_key_encoding = true,
  leader = { key = "Space", mods = "CTRL|SHIFT" },
  keys = keybinds.create_keybinds(),
  key_tables = keybinds.key_tables,
  mouse_bindings = keybinds.mouse_bindings,
  -- https://github.com/wez/wezterm/issues/2756
  webgpu_preferred_adapter = gpus[1],
  front_end = "WebGpu",
  -- macos full screen setting     setup with wezterm.on("gui-startup")
  -- native_macos_fullscreen_mode = true,
}

return config
