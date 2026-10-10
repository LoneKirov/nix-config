{config, ...}: {
  imports = [
    ./decluttarr
    ./flaresolverr
    ./gluetun
    ./profilarr
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./sabnzbd
    ./seerr
    ./sonarr
  ];

  config.virtualisation.quadlet.networks.arr = config.lib.quadlet.mkNetwork "Network for Arr";
}
