{config, ...}: {
  virtualisation.quadlet.containers.sabnzbd = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
  in {
    unitConfig = {
      Description = "Sabnbzd - Usenet";
    };
    containerConfig = {
      image = "lscr.io/linuxserver/sabnzbd:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.caddy.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      volumes = [
        "/srv/arr/sabnzbd:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/arr/data:/data:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
