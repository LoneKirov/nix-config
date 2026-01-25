local wezterm = require 'wezterm'

local module = {}

function module.fix_copy_paste(config)
  -- https://github.com/wezterm/wezterm/issues/6685
  wezterm.on('window-focus-changed', function(window, pane)
    wezterm.run_child_process { 'sh', '-c', 'wl-paste -n | wl-copy' }
  end)
end

function module.apply_tab_bar_config(config)
  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = true

  wezterm.on('format-tab-title', function(tab)
    local pane = tab.active_pane
    local title = pane.title
    if pane.domain_name then
      title = title .. ' - (' .. pane.domain_name .. ')'
    end
    return title
  end)
end

function module.apply_dms_theme(config)
  wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/colors/dank-theme.toml")
  config.window_background_opacity = 0.7
  config.color_scheme = "dank-theme"
end

function module.apply_domains(config)
  config.unix_domains = {
    {
      name = 'unix',
    },
  }
  config.ssh_domains = {} 
  for _, dom in ipairs(wezterm.default_ssh_domains()) do
    if string.find(dom.remote_address, ".host") == nil then
      dom.assume_shell = 'Posix'
      table.insert(config.ssh_domains, dom)
    end
  end
end

return module
