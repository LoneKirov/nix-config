{
  lib,
  osConfig,
  ...
}: let
  gui = osConfig.host.gui or false;
in {
  config = {
    programs.brave = {
      enable = lib.mkDefault gui;
      extensions = [];
      commandLineArgs = [];
    };
  };
}
