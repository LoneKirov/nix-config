{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
  inherit (config.virtualisation.quadlet) containers networks;
in {
  virtualisation.quadlet.containers.radarr = mkContainer {
    unitConfig = {
      Description = "Radarr - Movies";
      Requires = with containers; [
        qbittorrent.ref
        sabnzbd.ref
      ];
    };
    containerConfig = {
      image = "lscr.io/linuxserver/radarr:latest";
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
