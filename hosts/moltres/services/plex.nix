{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userBindRo containerUid containerGid;
  host-gid = toString config.users.groups.video.gid;
in {
  virtualisation.quadlet.builds.plex.buildConfig.file = "${./plex.Containerfile}";
  virtualisation.quadlet.containers.plex = mkContainer {
    unitConfig = {
      Description = "Plex";
    };
    containerConfig = {
      image = config.virtualisation.quadlet.builds.plex.ref;
      networks = ["host"];
      userns = "auto:gidmapping=${containerGid}:${host-gid}:1";
      environments = {
        TZ = config.time.timeZone;
        ALLOWED_NETWORKS = "10.0.1.0/24";
        PLEX_UID = containerUid;
        PLEX_GID = containerGid;
      };
      shmSize = "6G";
      devices = ["/dev/dri"];
      volumes = [
        (userBind "/srv/arr/plex/config" "/config")
        (userBind "/srv/arr/plex/optimized" "/optimized")
        (userBindRo "/srv/arr/plex/media" "/data/media.old")
        (userBindRo "/srv/arr/data/media" "/data/media")
        (userBindRo "/srv/syncthing/folders/Patreon" "/data/patreon")
      ];
      tmpfses = ["/transcode:size=10G"];
    };
    serviceConfig = {
      TimeoutStartSec = 900;
    };
  };

  services.caddy-podman.virtualHosts."plex.kanto.casa" = ''
    reverse_proxy host.containers.internal:32400
  '';
  networking.firewall = {
    allowedTCPPorts = [32400];
    allowedUDPPorts = [32410 32412 32413 32414]; # GDM discovery
  };
}
