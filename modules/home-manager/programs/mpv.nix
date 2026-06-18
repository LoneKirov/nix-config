{
  lib,
  osConfig,
  ...
}: let
  xserver = osConfig.services.xserver.enable or false;
in {
  programs.mpv.enable = lib.mkDefault xserver;
}
