{
  config,
  lib,
  ...
}: {
  services.gvfs.enable = lib.mkDefault config.services.xserver.enable;
}
