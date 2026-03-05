{config, ...}: {
  sops.secrets.decluttarr = {
    format = "dotenv";
    sopsFile = ./decluttarr.sops.env;
    key = "";
  };
  virtualisation.quadlet.containers.decluttarr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
  in {
    unitConfig = {
      Description = "Decluttar - Automatic cleanup";
      Requires = [
        config.virtualisation.quadlet.containers.sonarr.ref
        config.virtualisation.quadlet.containers.radarr.ref
        config.virtualisation.quadlet.containers.qbittorrent.ref
      ];
    };
    containerConfig = {
      image = "ghcr.io/manimatter/decluttarr:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.caddy.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      environmentFiles = [config.sops.secrets.decluttarr.path];
      volumes = [
        "${./config.yaml}:/app/config/config.yaml:ro,idmap=uids=@0-${container-uid}-1"
        "/srv/arr/data:/data:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
