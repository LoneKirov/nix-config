{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
in {
  virtualisation.quadlet.builds.qbittorrent.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.qbittorrent = mkContainer {
    unitConfig = {
      Description = "qBittorrent";
    };
    containerConfig = {
      image = config.virtualisation.quadlet.builds.qbittorrent.ref;
      networks = [config.virtualisation.quadlet.containers.gluetun.ref];
      environments = userEnv;
      volumes = [
        (userBind "/srv/arr/qbittorrent" "/config")
        (userBind "/srv/arr/data" "/data")
      ];
      healthCmd = "curl -fsS -o /dev/null http://localhost:8080/ || exit 1";
      healthInterval = "1m";
      healthTimeout = "5s";
      healthStartPeriod = "1m";
      healthRetries = 3;
    };
  };

  services.caddy-podman.virtualHosts."torrents.kanto.casa" = ''
    import reverse_proxy_with_auth gluetun:8080
  '';
}
