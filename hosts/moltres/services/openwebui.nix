{config, ...}: {
  config = {
    virtualisation.quadlet = {
      volumes.openwebui = {};
      networks.openwebui = {
        unitConfig = {
          Description = "Network for OpenWebUI";
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
      containers.openwebui = {
        unitConfig = {
          Description = "OpenWebUI server";
        };
        containerConfig = {
          image = "ghcr.io/open-webui/open-webui:main";
          autoUpdate = "registry";
          networks = [config.virtualisation.quadlet.networks.openwebui.ref];
          userns = "auto";
          volumes = [
            "${config.virtualisation.quadlet.volumes.openwebui.ref}:/app/backend/data:idmap"
          ];
        };
        serviceConfig = {
          Restart = "on-failure";
        };
        autoStart = true;
      };
    };
    services.caddy-podman.virtualHosts."openwebui.kanto.casa" = ''
      reverse_proxy openwebui:8080
    '';
  };
}
