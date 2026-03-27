{
  config,
  lib,
  ...
}: {
  services.syncthing = {
    enable = lib.mkDefault config.local.programs.dms-shell.enable;
    overrideDevices = false;
    overrideFolders = false;
  };
}
