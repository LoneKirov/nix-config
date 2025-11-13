{lib, ...}: {
  config = {
    programs.eza.enable = lib.mkDefault true;
  };
}
