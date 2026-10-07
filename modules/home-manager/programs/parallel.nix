{lib, ...}: {
  config.programs.parallel.enable = lib.mkDefault true;
}
