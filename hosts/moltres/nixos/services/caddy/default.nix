{config, ...}: {
  sops.secrets.caddy = {
    format = "dotenv";
    sopsFile = ../../../../../secrets/caddy.env;
    key = "";
  };
  virtualisation.quadlet = {
    networks.caddy = {
      unitConfig = {
        Description = "Network for Caddy exposed services";
        Wants = ["network-online.target"];
        After = ["network-online.target"];
      };
      networkConfig = {
        ipv6 = true;
        subnets = [
          "10.89.0.0/24"
          "fde6:1612:79ee:c19d::/64"
        ];
      };
      autoStart = true;
    };
    volumes.caddy = {};
    containers.caddy = {
      unitConfig = {
        Description = "Caddy services reverse proxy";
      };
      containerConfig = {
        image = "ghcr.io/caddybuilds/caddy-cloudflare:alpine";
        autoUpdate = "registry";
        networks = [config.virtualisation.quadlet.networks.caddy.ref];
        userns = "auto";
        ip = "10.89.0.17";
        ip6 = "fde6:1612:79ee:c19d::11";
        publishPorts = ["80:80" "443:443"];
        environmentFiles = [config.sops.secrets.caddy.path];
        environments = {
          HOSTNAME = "%H";
        };
        volumes = [
          "${config.virtualisation.quadlet.volumes.caddy.ref}:/data:idmap"
          "${./Caddyfile}:/etc/caddy/Caddyfile:ro,idmap"
        ];
      };
      serviceConfig = {
        Restart = "on-failure";
      };
      autoStart = true;
    };
  };
}
