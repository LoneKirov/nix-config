{config, ...}: {
  sops.secrets.gluetun = {
    format = "dotenv";
    sopsFile = ./gluetun.sops.env;
    key = "";
  };
  virtualisation.quadlet.containers.gluetun = {
    unitConfig = {
      Description = "Gluetun - VPN";
    };
    containerConfig = {
      image = "docker.io/qmcgaw/gluetun:latest";
      autoUpdate = "registry";
      networks = [config.virtualisation.quadlet.networks.caddy.ref];
      userns = "auto";
      addCapabilities = ["NET_ADMIN" "NET_RAW"];
      devices = ["/dev/net/tun"];
      environmentFiles = [config.sops.secrets.gluetun.path];
      healthCmd = "/gluetun-entrypoint healthcheck";
      healthInterval = "5s";
      healthTimeout = "5s";
      healthStartPeriod = "10s";
      healthRetries = 3;
      notify = "healthy";
    };
    serviceConfig = {
      Restart = "on-failure";
    };
    autoStart = true;
  };
}
