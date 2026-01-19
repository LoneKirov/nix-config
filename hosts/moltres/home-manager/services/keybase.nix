{ lib, ... }:

{
  config = {
    services.keybase.enable = lib.mkDefault true;
    services.kbfs.enable = lib.mkDefault true;
  };
}