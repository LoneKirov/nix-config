# The Pi firmware boots pftf's UEFI firmware, which then runs systemd-boot from
# the ESP as on a PC, rather than the extlinux setup nixos-hardware expects.
# Both firmwares and the Pi's config.txt sit on the ESP, copied there by hand,
# so NixOS neither manages nor versions them.
{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    ./disk-config.nix
  ];

  boot = {
    # lanzaboote's measured boot needs a TPM, which the Pi doesn't have
    lanzaboote.enable = false;
    loader.generic-extlinux-compatible.enable = false;
  };
  # swap in compressed RAM rather than on the SD card
  zramSwap.enable = true;
  # its only disk is the SD card, which has no SMART
  services.smartd.enable = false;
}
