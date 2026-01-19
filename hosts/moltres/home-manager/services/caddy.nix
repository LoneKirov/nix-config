{ config, lib, ... }:

let
  cfg = config.services.caddy;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    optionalString
    ;
in
{
  options.services.caddy = {
    enable = mkEnableOption "caddy";
    configPath = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/caddy";
      apply = toString;
      readOnly = true;
    };
    dataPath = mkOption {
      type = types.path;
      default = "${config.xdg.stateHome}/caddy";
      apply = toString;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "containers/systemd/caddy.network" = {
        text = ''
          [Unit]
          Description=Network for Caddy exposed services
          Wants=network-online.target
          After=network-online.target

          [Network]
          IPv6=true
          Subnet=10.89.0.0/24
          Subnet=fde6:1612:79ee:c19d::/64
        '';
        onChange = ''
          /usr/bin/systemctl --user daemon-reload
          /usr/bin/systemctl --user reload-or-restart caddy-network.service
        '';
      };

      "containers/systemd/caddy.container" = {
        text = ''
          [Unit]
          Description=Caddy services reverse proxy
          ${optionalString config.services.resilio-sync.enable ''
            After=resilio-sync.container
          ''}
          ${optionalString config.services.torrents.enable ''
            After=transmission.container
          ''}

          [Container]
          Image=ghcr.io/caddybuilds/caddy-cloudflare:alpine
          AutoUpdate=registry
          Network=caddy.network
          IP=10.89.0.17
          IP6=fde6:1612:79ee:c19d::11
          PublishPort=80:80
          PublishPort=443:443
          EnvironmentFile=${cfg.configPath}/caddy.env
          Environment=HOSTNAME=%H
          Volume=${cfg.configPath}/Caddyfile.common:/etc/caddy/Caddyfile.common:ro,Z
          Volume=${cfg.configPath}/Caddyfile.%H:/etc/caddy/Caddyfile:ro,Z
          Volume=${cfg.dataPath}:/data:Z

          [Service]
          Restart=always

          [Install]
          WantedBy=default.target
        '';
        onChange = ''
          /usr/bin/systemctl --user daemon-reload
          /usr/bin/systemctl --user reload-or-restart caddy.service
        '';
      };
    };
  };
}
