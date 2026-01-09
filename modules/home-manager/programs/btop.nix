{lib, ...}: {
  config.programs.btop.enable = lib.mkDefault true;
}
