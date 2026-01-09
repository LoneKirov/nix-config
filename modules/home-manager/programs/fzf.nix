{lib, ...}: {
  config = {
    programs.fzf.enable = lib.mkDefault true;
  };
}
