{
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
      fish.plugins = [
        {
          name = "fzf";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
      ];
    };
  };
}
