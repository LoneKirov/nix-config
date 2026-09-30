{
  config,
  lib,
  ...
}: {
  services.gvfs.enable = lib.mkDefault config.host.gui;
}
