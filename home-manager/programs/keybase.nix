{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.keybase.enable = lib.mkEnableOption "keybase";

  config = lib.mkIf config.programs.keybase.enable {
    home.packages = with pkgs; [
      kbfs
      keybase
    ];
  };
}
