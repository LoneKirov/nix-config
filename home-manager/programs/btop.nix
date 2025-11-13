{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.btop.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.btop.enable {
      home.packages = with pkgs; [
        btop
      ];
    })
  ];
}
