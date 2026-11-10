# What every Pi here shares, whatever the model. The Pi firmware boots pftf's
# UEFI firmware, which then runs systemd-boot from the ESP as on a PC. Both
# firmwares and the Pi's config.txt sit on the ESP, copied there by hand, so
# NixOS neither manages nor versions them.
{lib, ...}: {
  imports = [./disk-config.nix];

  boot = {
    # lanzaboote's measured boot needs a TPM, which the Pi doesn't have
    lanzaboote.enable = false;
    # the Pis have little RAM, so /tmp gets the same limit as the root tmpfs
    tmp.tmpfsSize = lib.mkDefault "25%";
  };
  # its only disk is the SD card, which has no SMART
  services.smartd.enable = false;
  # The Pis are appliances: a dead SD card means reinstalling from this flake
  # rather than restoring a backup
  btrbk.enable = lib.mkDefault false;
}
