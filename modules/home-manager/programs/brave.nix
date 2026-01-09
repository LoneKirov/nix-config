{
  osConfig,
  lib,
  ...
}: {
  config.programs.brave = {
    enable = lib.mkDefault osConfig.services.xserver.enable;
    extensions = [];
    commandLineArgs = [];
  };
}
