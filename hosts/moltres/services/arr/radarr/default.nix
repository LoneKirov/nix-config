{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
  inherit (config.virtualisation.quadlet) builds containers networks;
in {
  virtualisation.quadlet.builds.radarr.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.radarr = mkContainer {
    unitConfig = {
      Description = "Radarr - Movies";
      Requires = with containers; [
        qbittorrent.ref
        sabnzbd.ref
      ];
    };
    containerConfig = {
      image = builds.radarr.ref;
      networks = [networks.arr.ref];
      environments = userEnv;
      volumes = [
        (userBind "/srv/arr/radarr" "/config")
        (userBind "/srv/arr/data" "/data")
      ];
    };
  };

  services.caddy-podman.virtualHosts."radarr.kanto.casa" = ''
    import reverse_proxy_with_auth radarr:7878
  '';
}
