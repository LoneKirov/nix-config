{config, ...}: {
  sops.secrets.gluetun = {
    format = "dotenv";
    sopsFile = ./gluetun.sops.env;
    key = "";
  };
  virtualisation.quadlet.builds.gluetun.buildConfig.file = "${./Containerfile}";
  virtualisation.quadlet.containers.gluetun = config.lib.quadlet.mkContainer {
    unitConfig = {
      Description = "Gluetun - VPN";
    };
    containerConfig = {
      image = config.virtualisation.quadlet.builds.gluetun.ref;
      networks = [config.virtualisation.quadlet.networks.arr.ref];
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
  };
}
