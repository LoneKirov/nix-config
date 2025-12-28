{
  lib,
  pkgs,
  ...
}: {
  boot = {
    loader = {
      # Disable systemd-boot EFI boot loader. Lanzaboote handles it.
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    # Setup Lanzaboote for SecureBoot
    lanzaboote = {
      enable = true;
      # Using sbctl for key generation and management
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };

    # Enable systemd within initrd
    initrd.systemd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    sbctl
    tpm2-tools
    tpm2-tss
  ];
}
