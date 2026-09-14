{
  lib,
  osConfig,
  ...
}: let
  xserver = osConfig.services.xserver.enable or false;
in {
  config = {
    programs.brave = {
      enable = lib.mkDefault xserver;
      extensions = [];
      commandLineArgs = [];
    };
  };
}
