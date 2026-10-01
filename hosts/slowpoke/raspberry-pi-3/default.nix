{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  config.boot = {
    lanzaboote.enable = false;
    loader.generic-extlinux-compatible.enable = false;
  };
}
