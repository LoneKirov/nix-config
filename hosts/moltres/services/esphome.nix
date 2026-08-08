{config, ...}: {
  config = {
    virtualisation.quadlet = {
      volumes.esphome = {};
      networks.esphome = {
        unitConfig = {
          Description = "Network for ESPHome";
          Wants = ["network-online.target"];
          After = ["network-online.target"];
        };
        networkConfig = {
          ipv6 = true;
          options = {
            isolate = "strict";
          };
        };
        autoStart = true;
      };
      containers.esphome = {
        unitConfig = {
          Description = "ESPHome remote builder";
        };
        containerConfig = {
          image = "ghcr.io/esphome/esphome";
          autoUpdate = "registry";
          networks = [config.virtualisation.quadlet.networks.esphome.ref];
          publishPorts = ["6055:6055"];
          userns = "auto";
          volumes = [
            "${config.virtualisation.quadlet.volumes.esphome.ref}:/config:idmap"
          ];
        };
        serviceConfig = {
          Restart = "on-failure";
        };
        autoStart = true;
      };
    };
    services.caddy-podman.virtualHosts."esphome.kanto.casa" = ''
      import reverse_proxy_with_auth esphome:6052
    '';
  };
}
