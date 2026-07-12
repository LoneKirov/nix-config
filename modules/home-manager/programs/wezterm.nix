{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  niri = osConfig.programs.niri.enable or false;
  dms-shell = osConfig.programs.dms-shell.enable or false;
  xserver = osConfig.services.xserver.enable or false;
  fish = config.programs.fish.enable or false;
in {
  config = {
    home.packages = lib.optionals niri [pkgs.wl-clipboard-rs];
    programs.wezterm = let
      wezterm =
        if xserver
        then pkgs.wezterm
        else pkgs.wezterm.headless;
      mkLuaInline = lib.generators.mkLuaInline;
    in
      lib.mkMerge [
        {
          enable = lib.mkDefault true;
          package = wezterm;
        }
        # fonts
        {
          settings.font = mkLuaInline ''
            wezterm.font_with_fallback {
                'Maple Mono Normal NL NF CN',
                'JetBrainsMono NF',
                'Noto Color Emoji',
              }
          '';
        }
        # keybinds
        {
          settings = {
            leader = {
              key = "a";
              mods = "CTRL";
              timeout_milliseconds = 2000;
            };
            keys = [
              {
                key = "[";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.ActivateCopyMode";
              }
              {
                key = "c";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.SpawnTab('CurrentPaneDomain')";
              }
              {
                key = "n";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.ActivateTabRelative(1)";
              }
              {
                key = "p";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.ActivateTabRelative(-1)";
              }
              {
                key = "w";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.ShowTabNavigator";
              }
              {
                key = "&";
                mods = "LEADER|SHIFT";
                action = mkLuaInline "wezterm.action.CloseCurrentTab({ confirm = true })";
              }
              {
                key = " ";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.ShowLauncher";
              }
              {
                key = "d";
                mods = "LEADER";
                action = mkLuaInline "wezterm.action.DetachDomain('CurrentPaneDomain')";
              }
            ];
          };
        }
        # tab bar
        {
          settings = {
            tab_bar_at_bottom = true;
            hide_tab_bar_if_only_one_tab = true;
            use_fancy_tab_bar = true;
          };
          extraConfig = ''
            wezterm.on('format-tab-title', function(tab)
              local pane = tab.active_pane
              local title = pane.title
              if pane.domain_name then
                title = title .. ' - (' .. pane.domain_name .. ')'
              end
              return title
            end)
          '';
        }
        # domains
        {
          settings = {
            unix_domains = [{name = "unix";}];
            ssh_domains = mkLuaInline ''
              (function ()
                local domains = {};
                for _, dom in ipairs(wezterm.default_ssh_domains()) do
                  if string.find(dom.remote_address, ".host") == nil then
                    dom.assume_shell = 'Posix'
                    table.insert(domains, dom)
                  end
                end
                return domains;
              end)()
            '';
          };
        }
        # DMS theme
        (lib.mkIf dms-shell {
          settings = {
            window_background_opacity = 0.7;
            color_scheme = "dank-theme";
          };
          extraConfig = ''
            wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/colors/dank-theme.toml")
          '';
        })
        (lib.mkIf fish {
          settings = {
            default_prog = [(lib.getExe pkgs.fish)];
          };
        })
      ];
  };
}
