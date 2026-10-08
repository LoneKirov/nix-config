{
  config,
  lib,
  ...
}: {
  services.flatpak.enable = lib.mkDefault config.host.gui;
}
