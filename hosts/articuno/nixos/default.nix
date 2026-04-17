{lib, ...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    ./howdy.nix
    ./kirov
    ./lanzaboote.nix
    ./nvidia.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  # https://github.com/nix-community/lanzaboote/pull/564#issuecomment-41896858291
  boot.lanzaboote.measuredBoot.upstreamStaticMeasurements = lib.mkForce [
    "500-separator.pcrlock.d/300-0x00000000.pcrlock"
    "400-secureboot-separator.pcrlock.d/300-0x00000000.pcrlock"
  ];

  services = {
    xserver.enable = true;
    openssh.enable = lib.mkForce true;
  };

  time.hardwareClockInLocalTime = true;

  system.stateVersion = "26.05";

  local.udev.ledger.enable = true;
}
