{config, ...}: {
  virtualisation.quadlet.containers.radarr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
    inherit (config.virtualisation.quadlet) containers networks;
  in {
    unitConfig = {
      Description = "Radarr - Movies";
      Requires = with containers; [
        qbittorrent.ref
        sabnzbd.ref
      ];
    };
    containerConfig = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoUpdate = "registry";
      networks = [networks.arr.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
      };
      volumes = [
        "/srv/arr/radarr:/config:idmap=uids=@${host-uid}-${container-uid}-1"
        "/srv/arr/data:/data:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };

  services.caddy-podman.virtualHosts."radarr.kanto.casa" = ''
    import reverse_proxy_with_auth radarr:7878
  '';
}
