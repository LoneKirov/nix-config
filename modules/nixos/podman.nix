{
  config,
  inputs,
  lib,
  ...
}: let
  hostUid = toString config.users.users.${config.user.username}.uid;
  containerUid = "1000";
  containerGid = "1000";
  # matches every podman bridge; iptables and nftables spell the wildcard differently
  bridgeInterfaces =
    if config.networking.nftables.enable
    then "podman*"
    else "podman+";
in {
  imports = [inputs.quadlet-nix.nixosModules.quadlet];

  config = {
    lib.quadlet = {
      inherit bridgeInterfaces containerUid containerGid;

      mkContainer = container:
        lib.mkMerge [
          {
            containerConfig.userns = lib.mkDefault "auto";
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
      quadlet.enable = true;
      podman.autoPrune.enable = true;
    };

    # Containers build their images from Containerfiles beside their modules,
    # where Dependabot can update the pinned base images. A container names its
    # image by build unit, so its own unit doesn't change with the Containerfile;
    # restarting it reruns the build, which it requires.
    systemd.services = let
      inherit (config.virtualisation.quadlet) builds containers;
    in
      lib.mapAttrs (_: container: {
        restartTriggers = lib.mapAttrsToList (_: build: build.buildConfig.file) (
          lib.filterAttrs (_: build: build.ref == container.containerConfig.image) builds
        );
      })
      containers;

    persist.directories = lib.mkIf config.virtualisation.quadlet.enable [
      "/var/lib/containers"
    ];

    # nixpkgs only opens aardvark-dns on podman0; quadlet networks get their own bridges
    networking.firewall.interfaces.${bridgeInterfaces} = lib.mkIf config.virtualisation.quadlet.enable {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
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
