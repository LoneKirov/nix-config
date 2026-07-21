{
  lib,
  osConfig,
  ...
}: let
  inherit (lib) types;
  isWSL = osConfig.wsl.enable or false;
in {
  imports = [
    ./fonts.nix
    ./programs
    ./theme.nix
  ];

  options.wsl.enable = lib.mkOption {
    type = types.bool;
    default = isWSL;
  };

  config = {
    xdg.enable = true;
  };
}
