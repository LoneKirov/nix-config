{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      # extensions = [];
      # commandLineArgs = [];
    };
  };
}
