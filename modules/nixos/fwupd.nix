{
  config,
  lib,
  ...
}: let
  isWSL = config.wsl.enable or false;
in {
  services.fwupd.enable = lib.mkDefault (! isWSL);
}
