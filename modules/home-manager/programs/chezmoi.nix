{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.chezmoi.enable = lib.mkEnableOption "chezmoi";

  config = lib.mkMerge [
    {programs.chezmoi.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.chezmoi.enable {
      home.packages = with pkgs; [
        chezmoi
      ];
    })
  ];
}
