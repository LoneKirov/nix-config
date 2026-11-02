{config, ...}: let
  inherit (config.virtualisation.quadlet) builds networks volumes;
in {
  sops.secrets.immich-frame = {
    format = "dotenv";
    sopsFile = ./immich-frame.sops.env;
    key = "";
  };

  virtualisation.quadlet = {
    volumes.immich-frame = {};
    builds.immich-frame.buildConfig.file = "${./Containerfile}";
    containers.immich-frame = config.lib.quadlet.mkContainer {
      unitConfig = {
        Description = "ImmichFrame digital photo frame";
      };
      containerConfig = {
        image = builds.immich-frame.ref;
        networks = [networks.caddy.ref];
        # holds the admin password; without one, a new instance lets anyone who
        # reaches /admin choose it
        environmentFiles = [config.sops.secrets.immich-frame.path];
        environments = {
          TZ = config.time.timeZone;
        };
        # every other setting lives in a database here and is edited at /admin;
        # ImmichFrame doesn't read them from its environment
        volumes = [
          "${volumes.immich-frame.ref}:/app/Config:idmap"
        ];
      };
    };
  };

  # frames sign in with ImmichFrame's own AuthenticationSecret; they run
  # unattended, and Caddy's login would expire under them every day
  services.caddy-podman.virtualHosts."immich-frame.kanto.casa" = ''
    reverse_proxy immich-frame:8080
  '';
}
