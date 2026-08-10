{config, ...}: {
  config = {
    sops.secrets.pocket-id = {
      format = "dotenv";
      sopsFile = ./pocket-id.sops.env;
      key = "";
    };
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) networks;
    in {
      volumes.pocket-id = {};
      containers.pocket-id = {
        unitConfig = {
          Description = "Pocket ID OIDC Provider";
        };
        containerConfig = {
          image = "ghcr.io/pocket-id/pocket-id:v2";
          autoUpdate = "registry";
          networks = with networks; [caddy.ref];
          userns = "auto";
          environmentFiles = [config.sops.secrets.pocket-id.path];
          environments = {
            APP_URL = "https://pocket-id.kanto.casa";
            TRUST_PROXY = "false";
            MAXMIND_LICENSE_KEY = "";
          };
          volumes = [
            "${config.virtualisation.quadlet.volumes.pocket-id.ref}:/app/data:idmap"
          ];
          healthCmd = "/app/pocket-id healthcheck";
          healthInterval = "1m30s";
          healthTimeout = "5s";
          healthStartPeriod = "10s";
          healthRetries = 2;
        };
        serviceConfig = {
          Restart = "on-failure";
        };
        autoStart = true;
      };
    };
    services.caddy-podman.virtualHosts."pocket-id.kanto.casa" = ''
      reverse_proxy pocket-id:1411
    '';
  };
}
