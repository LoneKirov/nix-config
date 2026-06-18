{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.caddy-podman.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    default = {};
    description = "Accumulator for containerized Caddy virtual hosts.";
  };
  config = let
    cfg = config.services.caddy-podman.virtualHosts;
    caddyfile = pkgs.writeText "Caddyfile" ''
      {
              email caddy@adammill.dev
      }

      (cloudflare-tls) {
              tls {
                      dns cloudflare {$CLOUDFLARE_API_TOKEN}
                      propagation_timeout 60m
              }
      }

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (domain: extraConfig: ''
          ${domain} {
              import cloudflare-tls
              ${extraConfig}
          }
        '')
        cfg
      )}
    '';
  in {
    sops.secrets.caddy = {
      format = "dotenv";
      sopsFile = ./caddy.sops.env;
      key = "";
    };
    virtualisation.quadlet = {
      networks.caddy = {
        unitConfig = {
          Description = "Network for Caddy";
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
      volumes.caddy = {};
      containers.caddy = {
        unitConfig = {
          Description = "Caddy services reverse proxy";
        };
        containerConfig = {
          image = "ghcr.io/caddybuilds/caddy-cloudflare:alpine";
          autoUpdate = "registry";
          networks = [
            config.virtualisation.quadlet.networks.caddy.ref
            config.virtualisation.quadlet.networks.arr.ref
            config.virtualisation.quadlet.networks.monarch-pl-bridge.ref
          ];
          userns = "auto";
          publishPorts = ["80:80" "443:443"];
          environmentFiles = [config.sops.secrets.caddy.path];
          environments = {
            HOSTNAME = "%H";
          };
          volumes = [
            "${config.virtualisation.quadlet.volumes.caddy.ref}:/data:idmap"
            "${caddyfile}:/etc/caddy/Caddyfile:ro,idmap"
          ];
        };
        serviceConfig = {
          Restart = "on-failure";
        };
        autoStart = true;
      };
    };
  };
}
