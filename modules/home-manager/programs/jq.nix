{lib, ...}: {
  config = {
    programs.jq.enable = lib.mkDefault true;
  };
}
