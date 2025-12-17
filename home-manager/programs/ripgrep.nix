{lib, ...}: {
  config = {
    programs.ripgrep.enable = lib.mkDefault true;
  };
}
