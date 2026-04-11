{lib, ...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    ./kirov
    ./services
  ];

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  # https://github.com/nix-community/lanzaboote/pull/564#issuecomment-41896858291
  boot.lanzaboote.measuredBoot.upstreamStaticMeasurements = lib.mkForce [
    "500-separator.pcrlock.d/300-0x00000000.pcrlock"
    "400-secureboot-separator.pcrlock.d/300-0x00000000.pcrlock"
  ];

  services.xserver.enable = false;

  networking.firewall.enable = false;

  system = {
    autoUpgrade.enable = true;

    stateVersion = "26.05";
  };

  users.users.nixremote.openssh.authorizedKeys.keys = [(builtins.readFile ../../../keys/github.pub)];
}
