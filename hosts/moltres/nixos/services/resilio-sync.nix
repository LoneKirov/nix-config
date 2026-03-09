{config, ...}: {
  virtualisation.quadlet.containers.resilio-sync = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
  in {
    unitConfig = {
      Description = "Resilio Sync";
    };
    containerConfig = {
      image = "lscr.io/linuxserver/resilio-sync";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.caddy.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = "${container-uid}";
        PGID = "${container-gid}";
      };
      volumes = [
        "/srv/resilio-sync/config:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/resilio-sync/downloads:/downloads:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/resilio-sync/folders:/sync:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
