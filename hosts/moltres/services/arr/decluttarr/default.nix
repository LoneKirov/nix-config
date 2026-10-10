{config, ...}: let
  inherit (config.lib.quadlet) mkContainer userBind userEnv containerUid;
  inherit (config.virtualisation.quadlet) builds containers networks;
in {
  sops.secrets.decluttarr = {
    format = "dotenv";
    sopsFile = ./decluttarr.sops.env;
    key = "";
  };
  virtualisation.quadlet.builds.decluttarr.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.decluttarr = mkContainer {
    unitConfig = {
      Description = "Decluttar - Automatic cleanup";
      Requires = with containers; [
        sonarr.ref
        radarr.ref
        qbittorrent.ref
      ];
    };
    containerConfig = {
      image = builds.decluttarr.ref;
      networks = [networks.arr.ref];
      environments = userEnv;
      environmentFiles = [config.sops.secrets.decluttarr.path];
      volumes = [
        # store paths are owned by root
        "${./config.yaml}:/app/config/config.yaml:ro,idmap=uids=@0-${containerUid}-1"
        (userBind "/srv/arr/data" "/data")
      ];
    };
  };
}
