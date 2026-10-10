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
        };
      };
    };
    services.caddy-podman.virtualHosts."esphome.kanto.casa" = ''
      import reverse_proxy_with_auth esphome:6052
    '';
  };
}
