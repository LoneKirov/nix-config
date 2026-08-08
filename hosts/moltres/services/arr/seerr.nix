{config, ...}: {
  virtualisation.quadlet.containers.seerr = let
    host-uid = toString config.users.users.kirov.uid;
    container-uid = "1000";
    inherit (config.virtualisation.quadlet) containers networks;
  in {
    unitConfig = {
      Description = "Seerr - Media Library Manager";
      Requires = with containers; [
        sonarr.ref
        radarr.ref
      ];
    };
    containerConfig = {
      image = "ghcr.io/seerr-team/seerr:latest";
      autoUpdate = "registry";
      networks = [networks.arr.ref];
      userns = "auto";
      environments = {
        TZ = "America/Los_Angeles";
      };
      volumes = [
        "/srv/arr/seerr:/app/config:idmap=uids=@${host-uid}-${container-uid}-1"
      ];
      healthCmd = "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1";
      healthInterval = "15s";
      healthTimeout = "3s";
      healthStartPeriod = "20s";
      healthRetries = 3;
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };

  services.caddy-podman.virtualHosts."seerr.kanto.casa" = ''
    reverse_proxy seerr:5055
  '';
}
