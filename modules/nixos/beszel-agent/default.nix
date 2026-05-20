{config, ...}: {
  services.beszel.agent = {
    enable = true;
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
}
