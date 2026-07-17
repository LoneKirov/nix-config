local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_domain = 'WSL:NixOS'
config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = true;
config.hide_tab_bar_if_only_one_tab = true;
config.use_fancy_tab_bar = true;
config.window_background_opacity = 0.8;
config.font = wezterm.font_with_fallback {
  'Maple Mono NF CN',
  'JetBrainsMono Nerd Font',
}
config.keys = {
  {
    ["action"] = (wezterm.action.ActivateCopyMode),
    ["key"] = "[",
    ["mods"] = "LEADER"
  },
  {
    ["action"] = (wezterm.action.SpawnTab('CurrentPaneDomain')),
    ["key"] = "c",
    ["mods"] = "LEADER"
  },
  {
    ["action"] = (wezterm.action.ActivateTabRelative(1)),
    ["key"] = "n",
    ["mods"] = "LEADER"
  },
  {
    ["action"] = (wezterm.action.ActivateTabRelative(-1)),
    ["key"] = "p",
    ["mods"] = "LEADER"
  },
  {
    ["action"] = (wezterm.action.ShowTabNavigator),
    ["key"] = "w",
    ["mods"] = "LEADER"
  },
  {
    ["action"] = (wezterm.action.CloseCurrentTab({ confirm = true })),
    ["key"] = "&",
    ["mods"] = "LEADER|SHIFT"
  },
  {
    ["action"] = (wezterm.action.ShowLauncher),
    ["key"] = " ",
    ["mods"] = "LEADER"
  },
  {
    ["action"] = (wezterm.action.DetachDomain('CurrentPaneDomain')),
    ["key"] = "d",
    ["mods"] = "LEADER"
  }
}
config.leader = {
  ["key"] = "a",
  ["mods"] = "CTRL",
  ["timeout_milliseconds"] = 2000
}

return config
