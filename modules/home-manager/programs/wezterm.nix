{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    home.packages = lib.optionals config.programs.niri.enable [pkgs.wl-clipboard-rs];
    programs.wezterm = {
      enable = lib.mkDefault true;
      # https://github.com/wezterm/wezterm/issues/6685
      extraConfig = ''
        ${
          lib.optionalString config.programs.niri.enable ''
            -- https://github.com/wezterm/wezterm/issues/6685
            wezterm.on(
              'window-focus-changed',
              function(window, pane)
                wezterm.run_child_process { 'sh', '-c', 'wl-paste -n | wl-copy' }
              end
            )
          ''
        }
        local config = {}
        config.hide_tab_bar_if_only_one_tab = true
        config.window_background_opacity = 0.6
        ${lib.optionalString config.programs.dms-shell.enable ''
          wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/colors/dank-theme.toml")
          config.color_scheme = "dank-theme"
        ''}
        return config
      '';
    };
  };
}
