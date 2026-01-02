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
      programs.rbw = {
        enable = true;
        # workaround for email being required in HM settings
        package = pkgs.symlinkJoin {
          name = "rbw-wrapped";
          paths = let
            pinentry =
              if config.services.xserver.enable
              then lib.getExe' pkgs.pinentry-gnome3 "pinentry-gnome3"
              else lib.getExe' pkgs.pinentry-curses "pinentry-curses";
          in [
            (pkgs.writeShellScriptBin "pinentry" ''${pinentry} "$@"'')
            pkgs.rbw
          ];
        };
      };
      home.packages = with pkgs; [
        bitwarden-cli
      ];
    })
  ];
}
