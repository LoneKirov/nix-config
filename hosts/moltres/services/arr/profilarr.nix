{config, ...}: {
  virtualisation.quadlet.containers.profilarr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    container-gid = "1000";
    inherit (config.virtualisation.quadlet) containers networks;
  in {
    unitConfig = {
      Description = "Profilarr - Indexer management";
      Requires = with containers; [
        sonarr.ref
        radarr.ref
      ];
    };
    containerConfig = {
      image = "ghcr.io/dictionarry-hub/profilarr:latest";
      autoUpdate = "registry";
      networks = [networks.arr.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
        PUID = container-uid;
        PGID = container-gid;
        AUTH = "off";
        ORIGIN = "https://profilarr.kanto.casa";
      };
      volumes = [
        "/srv/arr/profilarr:/config:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };

  services.caddy-podman.virtualHosts."profilarr.kanto.casa" = ''
    reverse_proxy profilarr:6868
  '';
}
