{config, ...}: let
  inherit (config.lib.quadlet) mkContainer mkNetwork;
in {
  config = {
    virtualisation.quadlet = {
      volumes.openwebui = {};
      networks.openwebui = mkNetwork "Network for OpenWebUI";
      builds.openwebui.buildConfig.file = "${./openwebui.Containerfile}";
      containers.openwebui = mkContainer {
        unitConfig = {
          Description = "OpenWebUI server";
        };
        containerConfig = {
          image = config.virtualisation.quadlet.builds.openwebui.ref;
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
