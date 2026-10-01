{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    programs = {
      fzf = {
        enable = lib.mkDefault true;
        historyWidget.command = "";
      };
      fish.plugins = lib.mkIf config.programs.fzf.enable [
        {
          name = "fzf";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
      ];
    };
  };
}
