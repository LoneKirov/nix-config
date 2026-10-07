{
  config,
  lib,
  ...
}: {
  config.programs.brave.enable = lib.mkDefault config.host.gui;
}
