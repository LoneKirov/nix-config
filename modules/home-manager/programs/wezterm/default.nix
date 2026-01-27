{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    home.packages = lib.optionals config.programs.niri.enable [pkgs.wl-clipboard-rs];
    xdg.configFile = lib.mkIf config.programs.wezterm.enable {
      "wezterm/default_config.lua".source = ./default_config.lua;
      "wezterm/keybinds.lua".source = ./keybinds.lua;
    };
    programs.wezterm = {
      enable = lib.mkDefault true;
      # https://github.com/wezterm/wezterm/issues/6685
      extraConfig = ''
        local default_config = require 'default_config'
        local keybinds = require 'keybinds'

        local config = {}
        keybinds.apply_to_config(config)
        default_config.apply_fonts(config)
        default_config.apply_tab_bar_config(config)
        default_config.apply_domains(config)
        ${lib.optionalString config.programs.niri.enable ''
          default_config.fix_copy_paste(config)
        ''}
        ${lib.optionalString config.programs.dms-shell.enable ''
          default_config.apply_dms_theme(config)
        ''}
        return config
      '';
    };
  };
}
