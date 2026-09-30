{
  lib,
  osConfig,
  ...
}: let
  gui = osConfig.host.gui or false;
in {
  programs.mpv.enable = lib.mkDefault gui;
}
