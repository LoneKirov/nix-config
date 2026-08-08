{config, ...}: {
  virtualisation.quadlet.containers.prowlarr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
    inherit (config.virtualisation.quadlet) containers networks;
  in {
    unitConfig = {
      Description = "Prowlarr - Indexer management";
      Wants = with containers; [
        sonarr.ref
        radarr.ref
        flaresolverr.ref
      ];
    };
    containerConfig = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      autoUpdate = "registry";
      networks = [networks.arr.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      volumes = [
        "/srv/arr/prowlarr:/config:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };

  services.caddy-podman.virtualHosts."prowlarr.kanto.casa" = ''
    import reverse_proxy_with_auth prowlarr:9696
  '';
}
