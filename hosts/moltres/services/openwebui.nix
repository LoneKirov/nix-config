{config, ...}: let
  inherit (config.lib.quadlet) mkContainer mkNetwork;
in {
  config = {
    virtualisation.quadlet = {
      volumes.openwebui = {};
      networks.openwebui = mkNetwork "Network for OpenWebUI";
      containers.openwebui = mkContainer {
        unitConfig = {
          Description = "OpenWebUI server";
        };
        containerConfig = {
          image = "ghcr.io/open-webui/open-webui:main";
          networks = [config.virtualisation.quadlet.networks.openwebui.ref];
          volumes = [
            "${config.virtualisation.quadlet.volumes.openwebui.ref}:/app/backend/data:idmap"
          ];
        };
      };
    };
    services.caddy-podman.virtualHosts."openwebui.kanto.casa" = ''
      reverse_proxy vulpix.lan:8080
    '';
  };
}
