{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv;
  inherit (config.virtualisation.quadlet) builds containers networks;
in {
  virtualisation.quadlet.builds.profilarr.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.profilarr = mkContainer {
    unitConfig = {
      Description = "Profilarr - Indexer management";
      Requires = with containers; [
        sonarr.ref
        radarr.ref
      ];
    };
    containerConfig = {
      image = builds.profilarr.ref;
      networks = [networks.arr.ref];
      environments =
        userEnv
        // {
          AUTH = "off";
          ORIGIN = "https://profilarr.kanto.casa";
        };
      volumes = [
        (userBind "/srv/arr/profilarr" "/config")
      ];
    };
  };

  services.caddy-podman.virtualHosts."profilarr.kanto.casa" = ''
    import reverse_proxy_with_auth profilarr:6868
  '';
}
