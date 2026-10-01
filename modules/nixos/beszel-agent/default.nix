{
  config,
  lib,
  ...
}: let
  isWSL = config.host.wsl;
in {
  config = lib.mkMerge [
    {
      services.beszel.agent.enable = lib.mkDefault (! isWSL);
    }
    (lib.mkIf config.services.beszel.agent.enable {
      services.beszel.agent = {
        environment = {
          DOCKER_HOST = "unix:///run/podman/podman.sock";
        };
        environmentFile = config.sops.secrets.beszel-agent.path;
        smartmon.enable = true;
      };
      # allow access to podman socket
      systemd.services.beszel-agent.serviceConfig.SupplementaryGroups = "podman";
      sops.secrets.beszel-agent = {
        format = "dotenv";
        sopsFile = ./beszel-agent.sops.env;
        key = "";
      };
    })
  ];
}
