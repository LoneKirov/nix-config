_: {
  home-manager.users.kirov = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.wezterm.settings = {
      default_domain = "WSL:NixOS";
      wsl_domains = [
        {
          name = "WSL:NixOS";
          distribution = "NixOS";
          default_prog = [(lib.getExe pkgs.fish)];
          default_cwd = "~";
        }
      ];
    };

    home.activation = lib.mkIf config.programs.wezterm.enable {
      syncWindowsWezterm = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD cp -L -f ${config.xdg.configHome}/wezterm/wezterm.lua /mnt/c/Users/kirov/.wezterm.lua
      '';
    };
  };
}
