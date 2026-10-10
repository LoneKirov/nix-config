{config, ...}: {
  virtualisation.quadlet.builds.flaresolverr.buildConfig.file = "${./flaresolverr.Containerfile}";
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
    };
  };
}
