{config, ...}: {
  imports = [
    ./decluttarr
    ./flaresolverr.nix
    ./gluetun
    ./profilarr.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./sabnzbd.nix
    ./seerr.nix
    ./sonarr.nix
  ];

  config.virtualisation.quadlet.networks.arr = config.lib.quadlet.mkNetwork "Network for Arr";
}
