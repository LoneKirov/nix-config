{
  config,
  lib,
  ...
}: let
  isWSL = config.host.wsl;
in {
  services.fwupd.enable = lib.mkDefault (! isWSL);
}
