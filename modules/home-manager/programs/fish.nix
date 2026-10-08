{
  lib,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = lib.mkDefault true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    plugins = [
      {
        name = "autopair";
        inherit (pkgs.fishPlugins.autopair) src;
      }
    ];
  };
}
