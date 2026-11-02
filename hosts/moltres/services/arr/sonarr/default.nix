{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
  inherit (config.virtualisation.quadlet) builds containers networks;
in {
  virtualisation.quadlet.builds.sonarr.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.sonarr = mkContainer {
    unitConfig = {
      Description = "Sonarr - TV Shows";
      Requires = with containers; [
        qbittorrent.ref
        sabnzbd.ref
      ];
    };
    containerConfig = {
      image = builds.sonarr.ref;
      networks = [networks.arr.ref];
      environments = userEnv;
      volumes = [
        (userBind "/srv/arr/sonarr" "/config")
        (userBind "/srv/arr/data" "/data")
      ];
      healthCmd = "curl -fsS -o /dev/null http://localhost:8989/ping || exit 1";
      healthInterval = "1m";
      healthTimeout = "5s";
      healthStartPeriod = "1m";
      healthRetries = 3;
    };
  };

  services.caddy-podman.virtualHosts."sonarr.kanto.casa" = ''
    import reverse_proxy_with_auth sonarr:8989
  '';
}
