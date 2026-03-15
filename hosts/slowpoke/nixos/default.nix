{lib, ...}: {
  imports = [
    ./btrfs.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    ./kirov
    ./raspberry-pi-3
    ./nix.nix
    ./tailscale.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = false;

  networking.firewall.enable = false;

  system = {
    autoUpgrade = {
      enable = true;
      # don't want to run at the same time as moltres
      dates = lib.mkForce "*-*-* 04:00:00";
    };

    stateVersion = "26.05";
  };
}
