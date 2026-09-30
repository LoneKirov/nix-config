{
  config,
  inputs,
  lib,
  ...
}: let
  hostUid = toString config.users.users.${config.user.username}.uid;
  containerUid = "1000";
  containerGid = "1000";
in {
  imports = [inputs.quadlet-nix.nixosModules.quadlet];

  config = {
    lib.quadlet = {
      inherit containerUid containerGid;

      mkContainer = container:
        lib.mkMerge [
          {
            containerConfig = {
              autoUpdate = lib.mkDefault "registry";
              userns = lib.mkDefault "auto";
            };
            # quadlet-nix defaults to Restart=always
            serviceConfig.Restart = lib.mkDefault "on-failure";
          }
          container
        ];

      mkNetwork = description: {
        unitConfig = {
          Description = description;
          Wants = ["network-online.target"];
          After = ["network-online.target"];
        };
        networkConfig = {
          ipv6 = true;
          options.isolate = "strict";
        };
      };

      userBind = source: target: "${source}:${target}:idmap=uids=@${hostUid}-${containerUid}-1";
      userBindRo = source: target: "${source}:${target}:ro,idmap=uids=@${hostUid}-${containerUid}-1";

      userEnv = {
        TZ = config.time.timeZone;
        PUID = containerUid;
        PGID = containerGid;
      };
    };

    virtualisation = {
      quadlet = {
        enable = true;
        autoUpdate.enable = true;
      };
      podman.autoPrune.enable = true;
    };

    users.users.containers = {
      isSystemUser = true;
      autoSubUidGidRange = true;
      description = "User required by podman to get subuids from.";
      group = "containers";
    };
    users.groups.containers = {};
  };
}
