{
  config,
  lib,
  ...
}: {
  programs.mpv.enable = lib.mkDefault config.local.programs.dms-shell.enable;
}
