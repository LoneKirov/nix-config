{
  config,
  pkgs,
  ...
}: {
  services.glances = {
    enable = true;
    extraArgs = [
      "-C"
      "${./glances.conf}"
      "-w"
    ];
    # nixpkgs doesn't include optional deps for container monitoring
    package = pkgs.glances.overrideAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [
          pkgs.python3Packages.docker
          pkgs.python3Packages.requests
          pkgs.python3Packages.python-dateutil
        ];
    });
  };

  systemd.services.glances = {
    environment = {
      DOCKER_HOST = "127.0.0.1:2375";
    };
    requires = ["docker-socket-proxy.service"];
    after = ["docker-socket-proxy.service"];
  };

  virtualisation.quadlet = {
    networks.docker-socket-proxy = {
      unitConfig = {
        Description = "Network for docker-socket-proxy";
        Wants = ["network-online.target"];
        After = ["network-online.target"];
      };
      networkConfig = {
        ipv6 = true;
        options = {
          isolate = "strict";
        };
      };
      autoStart = true;
    };
    containers.docker-socket-proxy = let
      host-uid = "0";
      host-gid = "998"; # podman
      container-uid = "0";
      container-gid = "0";
    in {
      unitConfig = {
        Description = "Proxy podman socket as read-only docker tcp endpoint";
        Requires = [config.systemd.sockets.podman.name];
      };
      containerConfig = {
        image = "docker.io/tecnativa/docker-socket-proxy";
        autoUpdate = "registry";
        networks = [config.virtualisation.quadlet.networks.docker-socket-proxy.ref];
        userns = "auto";
        environments = {
          CONTAINERS = "1";
          IMAGES = "1";
        };
        publishPorts = ["127.0.0.1:2375:2375"];
        volumes = [
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro,idmap=uids=@${host-uid}-${container-uid}-1;gids=@${host-gid}-${container-gid}-1"
        ];
      };
      serviceConfig = {
        Restart = "on-failure";
      };
      autoStart = true;
    };
  };

  local.services.caddy.virtualHosts."glances.moltres.kanto.casa" = ''
    reverse_proxy host.containers.internal:61208
  '';
}
