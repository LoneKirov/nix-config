{...}: {
  config = {
    programs.wezterm = {
      enable = true;
      # https://github.com/wezterm/wezterm/issues/6685
      extraConfig = ''
        -- https://github.com/wezterm/wezterm/issues/6685
        wezterm.on(
          'window-focus-changed',
          function(window, pane)
            wezterm.run_child_process { 'sh', '-c', 'wl-paste -n | wl-copy' }
          end
        )
        local config = {}
        config.hide_tab_bar_if_only_one_tab = true
        config.window_background_opacity = 0.6
        return config
      '';
    };
  };
}
