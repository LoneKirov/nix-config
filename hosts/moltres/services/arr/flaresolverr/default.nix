{config, ...}: {
  virtualisation.quadlet.builds.flaresolverr.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.flaresolverr = config.lib.quadlet.mkContainer {
    unitConfig = {
      Description = "Flaresolverr - Bypass Cloudflare protection for Indexers";
    };
    containerConfig = {
      image = config.virtualisation.quadlet.builds.flaresolverr.ref;
      networks = [config.virtualisation.quadlet.networks.arr.ref];
      environments = {
        TZ = config.time.timeZone;
      };
      healthCmd = "curl -fsS -o /dev/null http://localhost:8191/health || exit 1";
      healthInterval = "1m";
      healthTimeout = "5s";
      healthStartPeriod = "1m";
      healthRetries = 3;
    };
  };
}
