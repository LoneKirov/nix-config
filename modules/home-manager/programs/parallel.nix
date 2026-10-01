{
  lib,
  pkgs,
  ...
}: {
  config.programs.parallel = {
    enable = lib.mkDefault true;
    package = pkgs.parallel;
  };
}
