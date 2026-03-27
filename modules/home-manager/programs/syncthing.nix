{
  config,
  lib,
  ...
}: {
  services.syncthing = {
    enable = lib.mkDefault config.local.programs.dms-shell.enable;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.alwaysLocalNets = [
      "100.64.0.0/10"
      "fd7a:115c:a1e0::/48"
    ];
  };
}
