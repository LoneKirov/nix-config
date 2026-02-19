{config, ...}: {
  virtualisation.quadlet.containers.transmission = {
    unitConfig = {
      Description = "Transmission";
    };
    containerConfig = let
      host-uid = toString config.users.users.kirov.uid;
      container-uid = "0";
    in {
      image = "lscr.io/linuxserver/transmission:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.containers.gluetun.ref];
      userns = "auto";
      environments = {
        PUID = "0";
        PGID = "0";
        WHITELIST = "127.0.0.1,10.*.*.*";
      };
      volumes = [
        "/srv/torrents/config:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/torrents/downloads:/downloads:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/torrents/watch:/watch:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
