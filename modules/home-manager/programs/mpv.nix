{
  config,
  lib,
  ...
}: let
  gui = config.host.gui;
in {
  programs.mpv.enable = lib.mkDefault gui;
}
