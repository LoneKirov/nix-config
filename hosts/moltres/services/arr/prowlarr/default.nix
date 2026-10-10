{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
  inherit (config.virtualisation.quadlet) builds containers networks;
in {
  virtualisation.quadlet.builds.prowlarr.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.prowlarr = mkContainer {
    unitConfig = {
      Description = "Prowlarr - Indexer management";
      Wants = with containers; [
        sonarr.ref
        radarr.ref
        flaresolverr.ref
      ];
    };
    containerConfig = {
      image = builds.prowlarr.ref;
      networks = [networks.arr.ref];
      environments = userEnv;
      volumes = [
        (userBind "/srv/arr/prowlarr" "/config")
      ];
    };
  };

  services.caddy-podman.virtualHosts."prowlarr.kanto.casa" = ''
    import reverse_proxy_with_auth prowlarr:9696
  '';
}
