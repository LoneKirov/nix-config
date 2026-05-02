{...}: {
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

  config.virtualisation.quadlet.networks.arr = {
    unitConfig = {
      Description = "Network for Arr";
      Wants = ["network-online.target"];
      After = ["network-online.target"];
    };
    networkConfig = {
      ipv6 = true;
      options = {
        isolate = "strict";
      };
    };
    autoStart = true;
  };
}
