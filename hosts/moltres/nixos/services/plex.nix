{...}: {
  virtualisation.quadlet.containers.plex = {
    unitConfig = {
      Description = "Plex";
    };
    containerConfig = {
      image = "docker.io/plexinc/pms-docker:plexpass";
      autoUpdate = "registry";
      networks = ["host"];
      # host group is 26 is video for /dev/dri access
      userns = "auto:gidmapping=1000:26:1";
      environments = {
        TZ = "America/Los_Angeles";
        ALLOWED_NETWORKS = "10.0.1.0/24";
        PLEX_UID = "1000";
        PLEX_GID = "1000";
      };
      shmSize = "6G";
      devices = ["/dev/dri"];
      volumes = [
        "/srv/plex/config:/config:idmap=uids=@1000-1000-1"
        "/srv/plex/optimized:/optimized:idmap=uids=@1000-1000-1"
        "/srv/plex/media:/data/media:ro,idmap=uids=@1000-1000-1"
        "/srv/resilio-sync/folders/Patreon:/data/patreon:ro,idmap=uids=@1000-1000-1"
        "/srv/torrents/downloads/complete:/data/torrents:ro,idmap=uids=@1000-1000-1"
      ];
      tmpfses = ["/transcode:size=10G"];
    };
    serviceConfig = {
      TimeoutStartSec = 900;
    };
    autoStart = true;
  };
}
