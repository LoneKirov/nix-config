{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.bw.enable = lib.mkEnableOption "bw";

  config = lib.mkMerge [
    {programs.bw.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.bw.enable {
      home.packages = with pkgs; [
        bitwarden-cli
      ];
    })
  ];
}
