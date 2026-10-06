{
  config,
  lib,
  ...
}: let
  gui = config.host.gui;
in {
  config = {
    programs.brave = {
      enable = lib.mkDefault gui;
      extensions = [];
      commandLineArgs = [];
    };
  };
}
