{
  lib,
  osConfig,
  ...
}: let
  dms-shell = osConfig.programs.dms-shell.enable or false;
in {
  services.syncthing = {
    enable = lib.mkDefault dms-shell;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.alwaysLocalNets = [
      "100.64.0.0/10"
      "fd7a:115c:a1e0::/48"
    ];
  };
}
