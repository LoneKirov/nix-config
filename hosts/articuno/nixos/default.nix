{lib, ...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    ./howdy.nix
    ./kirov
    ./nvidia.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services = {
    xserver.enable = true;
    openssh.enable = lib.mkForce true;
  };

  time.hardwareClockInLocalTime = true;

  system.stateVersion = "26.05";

  local.udev.ledger.enable = true;
}
