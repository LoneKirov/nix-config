{config, ...}: {
  config = {
    sops.secrets.pocket-id = {
      format = "dotenv";
      sopsFile = ./pocket-id.sops.env;
      key = "";
    };
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) builds networks;
    in {
      volumes.pocket-id = {};
      builds.pocket-id.buildConfig.file = "${./Containerfile}";
      containers.pocket-id = config.lib.quadlet.mkContainer {
        unitConfig = {
          Description = "Pocket ID OIDC Provider";
        };
        containerConfig = {
          image = builds.pocket-id.ref;
          networks = with networks; [caddy.ref];
          environmentFiles = [config.sops.secrets.pocket-id.path];
          environments = {
            APP_URL = "https://pocket-id.kanto.casa";
            TRUST_PROXY = "true";
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
      };
    };
    services.caddy-podman.virtualHosts."pocket-id.kanto.casa" = ''
      reverse_proxy pocket-id:1411
    '';
  };
}
