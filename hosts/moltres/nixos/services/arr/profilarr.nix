{config, ...}: {
  virtualisation.quadlet.containers.profilarr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
  in {
    unitConfig = {
      Description = "Profilarr - Indexer management";
      Requires = [
        config.virtualisation.quadlet.containers.sonarr.ref
        config.virtualisation.quadlet.containers.radarr.ref
      ];
    };
    containerConfig = {
      image = "docker.io/santiagosayshey/profilarr:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.caddy.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      volumes = [
        "/srv/arr/profilarr:/config:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
