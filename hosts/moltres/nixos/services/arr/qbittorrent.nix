{config, ...}: {
  virtualisation.quadlet.containers.qbittorrent = {
    unitConfig = {
      Description = "qBittorrent";
    };
    containerConfig = let
      host-uid = toString config.users.users.kirov.uid;
      container-uid = "1000";
      container-gid = "1000";
    in {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.containers.gluetun.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      volumes = [
        "/srv/arr/qbittorrent:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/arr/data:/data:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
