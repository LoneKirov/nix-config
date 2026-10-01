{
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./lanzaboote.nix
    ./services
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  # tailnet access is governed by Tailscale ACLs
  networking.firewall.trustedInterfaces = ["tailscale0"];
  services.tailscale.openFirewall = true;
  system = {
    autoUpgrade.enable = true;
    stateVersion = "26.05";
  };
  hardware.facter.reportPath = ./facter.json;
}
