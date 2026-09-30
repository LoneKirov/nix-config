{config, ...}: {
  virtualisation.quadlet.containers.flaresolverr = config.lib.quadlet.mkContainer {
    unitConfig = {
      Description = "Flaresolverr - Bypass Cloudflare protection for Indexers";
    };
    containerConfig = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      networks = [config.virtualisation.quadlet.networks.arr.ref];
      environments = {
        TZ = config.time.timeZone;
      };
    };
  };
}
