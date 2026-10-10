{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
  inherit (config.virtualisation.quadlet) builds containers networks;
in {
  virtualisation.quadlet.builds.sonarr.buildConfig.file = "${./sonarr.Containerfile}";
  virtualisation.quadlet.containers.sonarr = mkContainer {
    unitConfig = {
      Description = "Sonarr - TV Shows";
      Requires = with containers; [
        qbittorrent.ref
        sabnzbd.ref
      ];
    };
    containerConfig = {
      image = builds.sonarr.ref;
      networks = [networks.arr.ref];
      environments = userEnv;
      volumes = [
        (userBind "/srv/arr/sonarr" "/config")
        (userBind "/srv/arr/data" "/data")
      ];
    };
  };

  services.caddy-podman.virtualHosts."sonarr.kanto.casa" = ''
    import reverse_proxy_with_auth sonarr:8989
  '';
}
