{config, ...}: {
  virtualisation.quadlet.containers.flaresolverr = {
    unitConfig = {
      Description = "Flaresolverr - Bypass Cloudflare protection for Indexers";
    };
    containerConfig = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.arr.ref];
      userns = "auto";
      environments = {
        TZ = config.time.timeZone;
      };
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
