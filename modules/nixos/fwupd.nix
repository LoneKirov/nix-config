{
  config,
  lib,
  ...
}: let
  isWSL = config.host.wsl;
in {
  services.fwupd.enable = lib.mkDefault (! isWSL);
  persist.directories = lib.mkIf config.services.fwupd.enable [
    "/var/lib/fwupd"
  ];
}
