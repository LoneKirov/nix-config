local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
  config.leader = {
    key = 'a',
    mods = 'CTRL',
    timeout_milliseconds = 2000,
  }
  config.keys = {
    {
      key = '[',
      mods = 'LEADER',
      action = wezterm.action.ActivateCopyMode,
    },
    {
      key = 'c',
      mods = 'LEADER',
      action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(1),
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(-1),
    },
    {
      key = 'w',
      mods = 'LEADER',
      action = wezterm.action.ShowTabNavigator,
    },
    {
      key = '&',
      mods = 'LEADER|SHIFT',
      action = wezterm.action.CloseCurrentTab{ confirm = true },
    },
    {
      key = ' ',
      mods = 'LEADER',
      action = wezterm.action.ShowLauncher,
    },
    {
      key = 'd',
      mods = 'LEADER',
      action = wezterm.action.DetachDomain 'CurrentPaneDomain',
    },
  }
end

return module
