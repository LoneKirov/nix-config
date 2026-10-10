{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
in {
  virtualisation.quadlet.builds.sabnzbd.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.sabnzbd = mkContainer {
    unitConfig = {
      Description = "Sabnbzd - Usenet";
    };
    containerConfig = {
      image = config.virtualisation.quadlet.builds.sabnzbd.ref;
      networks = [config.virtualisation.quadlet.networks.arr.ref];
      environments = userEnv;
      volumes = [
        (userBind "/srv/arr/sabnzbd" "/config")
        (userBind "/srv/arr/data" "/data")
      ];
    };
  };

  services.caddy-podman.virtualHosts."sabnzbd.kanto.casa" = ''
    import reverse_proxy_with_auth sabnzbd:8080
  '';
}
