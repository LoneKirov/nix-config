{config, ...}: {
  virtualisation.quadlet.containers.sonarr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
  in {
    unitConfig = {
      Description = "Sonarr - TV Shows";
      Requires = [
        config.virtualisation.quadlet.containers.qbittorrent.ref
        config.virtualisation.quadlet.containers.sabnzbd.ref
      ];
    };
    containerConfig = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.caddy.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      volumes = [
        "/srv/arr/sonarr:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/arr/data:/data:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
