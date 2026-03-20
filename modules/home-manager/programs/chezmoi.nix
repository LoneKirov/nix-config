{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.programs.chezmoi.enable = lib.mkEnableOption "chezmoi";

  config = lib.mkMerge [
    {local.programs.chezmoi.enable = lib.mkDefault true;}
    (lib.mkIf config.local.programs.chezmoi.enable {
      home.packages = with pkgs; [
        chezmoi
      ];
    })
  ];
}
