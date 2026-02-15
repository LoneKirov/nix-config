{config, ...}: {
  virtualisation.quadlet.containers.plex = let
    host-uid = toString config.users.users.kirov.uid;
    # host group is 26 is video for /dev/dri access
    host-gid = "26";
    container-uid = "1000";
    container-gid = "1000";
  in {
    unitConfig = {
      Description = "Plex";
    };
    containerConfig = {
      image = "docker.io/plexinc/pms-docker:plexpass";
      autoUpdate = "registry";
      networks = ["host"];
      userns = "auto:gidmapping=${container-gid}:${host-gid}:1";
      environments = {
        TZ = "America/Los_Angeles";
        ALLOWED_NETWORKS = "10.0.1.0/24";
        PLEX_UID = "${container-uid}";
        PLEX_GID = "${container-gid}";
      };
      shmSize = "6G";
      devices = ["/dev/dri"];
      volumes = [
        "/srv/plex/config:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/plex/optimized:/optimized:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/plex/media:/data/media:ro,idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/resilio-sync/folders/Patreon:/data/patreon:ro,idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/torrents/downloads/complete:/data/torrents:ro,idmap=uids=@${host-uid}-${container-uid}-1"
      ];
      tmpfses = ["/transcode:size=10G"];
    };
    serviceConfig = {
      TimeoutStartSec = 900;
    };
    autoStart = true;
  };
}
