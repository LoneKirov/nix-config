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
    autoUpgrade = {
      enable = true;
      # late enough to rarely cut off plex, and done well before slowpoke's
      # 05:00 upgrade pulls from the cache this host serves
      dates = "*-*-* 03:00:00";
    };
    stateVersion = "26.05";
  };
  hardware.facter.reportPath = ./facter.json;
}
