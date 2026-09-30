{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind;
  inherit (config.virtualisation.quadlet) containers networks;
in {
  virtualisation.quadlet.containers.seerr = mkContainer {
    unitConfig = {
      Description = "Seerr - Media Library Manager";
      Requires = with containers; [
        sonarr.ref
        radarr.ref
      ];
    };
    containerConfig = {
      image = "ghcr.io/seerr-team/seerr:latest";
      networks = [networks.arr.ref];
      environments = {
        TZ = config.time.timeZone;
      };
      volumes = [
        (userBind "/srv/arr/seerr" "/app/config")
      ];
      healthCmd = "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1";
      healthInterval = "15s";
      healthTimeout = "3s";
      healthStartPeriod = "20s";
      healthRetries = 3;
    };
  };

  services.caddy-podman.virtualHosts."seerr.kanto.casa" = ''
    reverse_proxy seerr:5055
  '';
}
