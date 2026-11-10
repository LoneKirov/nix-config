{inputs, ...}: {
  imports = [
    ../raspberry-pi
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  # nixos-hardware's module expects extlinux, but pftf's UEFI firmware runs
  # systemd-boot (see ../raspberry-pi)
  boot.loader.generic-extlinux-compatible.enable = false;
  # swap in compressed RAM rather than on the SD card
  zramSwap.enable = true;
}
