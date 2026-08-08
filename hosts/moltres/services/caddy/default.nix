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
    trustLogins = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (domain: extraConfig: ''
        trust login redirect uri domain exact ${domain} path prefix /
      '')
      cfg
    );
    domains = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (domain: extraConfig: ''
        ${domain} {
          ${extraConfig}
        }
      '')
      cfg
    );
    caddyfile = pkgs.writeText "Caddyfile" ''
      {
        email caddy@adammill.dev
        order authenticate before respond
        security {
          oauth identity provider generic {
            delay_start 3
            realm generic
            driver generic
            client_id {$POCKET_ID_CLIENT_ID}
            client_secret {$POCKET_ID_SECRET}
            scopes openid email profile
            base_auth_url https://pocket-id.kanto.casa
            metadata_url https://pocket-id.kanto.casa/.well-known/openid-configuration
          }
          authentication portal kanto_portal {
            crypto default token lifetime 86400
            enable identity provider generic
            cookie insecure off
            cookie samesite lax
            cookie domain kanto.casa
            ${trustLogins}
            transform user {
              match realm generic
              action add role user
            }
          }
          authorization policy kanto_policy {
            set auth url /caddy-security/oauth2/generic
            allow roles user
            inject headers with claims
          }
        }
      }

      (reverse_proxy_with_auth) {
        @auth {
          path /caddy-security/*
        }
        route @auth {
          authenticate with kanto_portal
        }
        route /* {
          authorize with kanto_policy
          reverse_proxy {args[0]} {
            {block}
          }
        }
      }

      *.kanto.casa {
      	tls {
      	  dns cloudflare {$CLOUDFLARE_API_TOKEN}
      	  propagation_timeout 60m
      	}
      	abort
      }

      ${domains}
    '';
    caddyFileFormatted =
      pkgs.runCommandLocal "Caddyfile" {
        nativeBuildInputs = [pkgs.caddy];
      } ''
        caddy fmt - < ${caddyfile} > $out
      '';
  in {
    sops.secrets.caddy = {
      format = "dotenv";
      sopsFile = ./caddy.sops.env;
      key = "";
    };
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) builds networks volumes;
    in {
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
      builds.caddy = {
        unitConfig = {
          Description = "Image build for caddy";
        };
        buildConfig = {
          file = "${pkgs.writeText "caddy.Containerfile" ''
            FROM docker.io/library/caddy:2-builder AS builder

            RUN xcaddy build \
                --with github.com/caddy-dns/cloudflare \
                --with github.com/greenpau/caddy-security

            FROM docker.io/library/caddy:2

            COPY --from=builder /usr/bin/caddy /usr/bin/caddy
          ''}";
        };
      };
      containers.caddy = {
        unitConfig = {
          Description = "Caddy services reverse proxy";
        };
        containerConfig = {
          image = builds.caddy.ref;
          networks = with networks; [
            caddy.ref
            arr.ref
            monarch-pl-bridge.ref
            esphome.ref
            openwebui.ref
          ];
          userns = "auto";
          publishPorts = ["80:80" "443:443"];
          environmentFiles = [config.sops.secrets.caddy.path];
          environments = {
            HOSTNAME = "%H";
          };
          volumes = [
            "${volumes.caddy.ref}:/data:idmap"
            "${caddyFileFormatted}:/etc/caddy/Caddyfile:ro,idmap"
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
