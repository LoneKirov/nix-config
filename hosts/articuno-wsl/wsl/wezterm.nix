_: {
  user.hm = {
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
        if winhome=$(${config.windows.profile}); then
          run cp -L -f ${config.xdg.configHome}/wezterm/wezterm.lua "$winhome/.wezterm.lua"
        else
          warnEcho "Couldn't find the Windows profile; skipping WezTerm config sync"
        fi
      '';
    };
  };
}
