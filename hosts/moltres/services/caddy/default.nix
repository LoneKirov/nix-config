{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.caddy-podman = {
    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = {};
      description = "Accumulator for containerized Caddy virtual hosts.";
    };
    wildcardDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["*.example.com"];
      description = ''
        Accumulator for wildcard domains, such as `*.example.com`, to get a
        certificate for through the Cloudflare DNS challenge. Virtual hosts
        under one use its certificate instead of getting their own, and
        requests for its subdomains that match no virtual host are aborted.
      '';
    };
  };
  config = let
    cfg = config.services.caddy-podman;
    containerAddHosts = lib.mapAttrsToList (domain: _: "${domain}:127.0.0.1") cfg.virtualHosts;
    trustLogins = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (domain: _: ''
        trust login redirect uri domain exact ${domain} path prefix /
      '')
      cfg.virtualHosts
    );
    wildcards = lib.concatMapStringsSep "\n" (domain: ''
      ${domain} {
        tls {
          dns cloudflare {$CLOUDFLARE_API_TOKEN}
          # kanto.casa has split DNS: the LAN answers only A records for it
          # and redirects all port-53 traffic, so the zone lookup and the
          # propagation check would never see the public zone. OpenDNS also
          # answers on port 5353, which the router lets moltres reach.
          resolvers 208.67.222.222:5353 208.67.220.220:5353
          propagation_timeout 60m
        }
        abort
      }
    '') (lib.unique cfg.wildcardDomains);
    domains = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (domain: extraConfig: ''
        ${domain} {
          ${extraConfig}
        }
      '')
      cfg.virtualHosts
    );
    caddyfile = pkgs.writeText "Caddyfile" ''
      {
        email caddy@adammill.dev
        order authenticate before respond
        security {
          oauth identity provider generic {
            delay_start 3
            # Discovery goes through this Caddy and only runs at startup. Once the
            # attempts run out, logins fail with "OAuth provider is not ready" until
            # Caddy restarts, so keep trying for an hour.
            retry_attempts 720
            retry_interval 5
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

      ${wildcards}

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
      inherit (config.virtualisation.quadlet) builds containers networks volumes;
      inherit (config.lib.quadlet) mkContainer mkNetwork;
    in {
      networks.caddy = mkNetwork "Network for Caddy";
      volumes.caddy = {};
      builds.caddy = {
        unitConfig = {
          Description = "Image build for caddy";
        };
        buildConfig.file = "${./Containerfile}";
      };
      containers.caddy = mkContainer {
        unitConfig = {
          Description = "Caddy services reverse proxy";
          After = [containers.pocket-id.ref];
        };
        containerConfig = {
          image = builds.caddy.ref;
          networks = with networks; [
            caddy.ref
            arr.ref
            esphome.ref
          ];
          publishPorts = ["80:80" "443:443"];
          addHosts = containerAddHosts;
          environmentFiles = [config.sops.secrets.caddy.path];
          environments = {
            HOSTNAME = "%H";
          };
          volumes = [
            "${volumes.caddy.ref}:/data:idmap"
            "${caddyFileFormatted}:/etc/caddy/Caddyfile:ro,idmap"
          ];
        };
      };
    };
    services.caddy-podman.wildcardDomains = [
      "*.kanto.casa"
      "*.moltres.kanto.casa"
    ];
    services.caddy-podman.virtualHosts = {
      "openwebui.kanto.casa" = ''
        reverse_proxy vulpix.lan:8080
      '';
      "kvm.moltres.kanto.casa" = ''
        reverse_proxy moltres-kvm.lan:443 {
          transport http {
            tls
            tls_insecure_skip_verify
          }
        }
      '';
    };
  };
}
