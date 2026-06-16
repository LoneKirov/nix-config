{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  config.boot = {
    lanzaboote.enable = lib.mkForce false;
    loader.generic-extlinux-compatible.enable = lib.mkForce false;
  };
}
