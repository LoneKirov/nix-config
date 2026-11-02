{config, ...}: let
  inherit (config.lib.quadlet) mkContainer mkNetwork;
in {
  config = {
    virtualisation.quadlet = {
      volumes.esphome = {};
      networks.esphome = mkNetwork "Network for ESPHome";
      builds.esphome.buildConfig.file = "${./Containerfile}";
      containers.esphome = mkContainer {
        unitConfig = {
          Description = "ESPHome remote builder";
        };
        containerConfig = {
          image = config.virtualisation.quadlet.builds.esphome.ref;
          networks = [config.virtualisation.quadlet.networks.esphome.ref];
          publishPorts = ["6055:6055"];
          volumes = [
            "${config.virtualisation.quadlet.volumes.esphome.ref}:/config:idmap"
          ];
          healthCmd = "curl -fsS -A HealthCheck -o /dev/null http://localhost:6052/version || exit 1";
          healthInterval = "1m";
          healthTimeout = "5s";
          healthStartPeriod = "1m";
          healthRetries = 3;
        };
      };
    };
    services.caddy-podman.virtualHosts."esphome.kanto.casa" = ''
      import reverse_proxy_with_auth esphome:6052
    '';
  };
}
