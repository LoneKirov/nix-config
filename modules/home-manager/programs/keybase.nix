{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.programs.keybase.enable = lib.mkEnableOption "keybase";

  config = lib.mkIf config.local.programs.keybase.enable {
    home.packages = with pkgs; [
      kbfs
      keybase
    ];
  };
}
