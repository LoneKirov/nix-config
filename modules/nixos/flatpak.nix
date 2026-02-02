{
  config,
  lib,
  ...
}: {
  # enable flatpak on the system level if we're on a gui system
  services.flatpak.enable = lib.mkDefault config.services.xserver.enable;
}
