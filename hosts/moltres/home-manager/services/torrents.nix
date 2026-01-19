{ config, lib, ... }:

let
  cfg = config.services.torrents;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.services.torrents = {
    enable = mkEnableOption "torrents";
    configPath = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/torrents";
      apply = toString;
      readOnly = true;
    };
    dataPath = mkOption {
      type = types.path;
      default = "${config.xdg.stateHome}/torrents";
      apply = toString;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "containers/systemd/gluetun.container" = {
        text = ''
          [Unit]
          Description=gluetun vpn

          [Container]
          Network=caddy.network
          Image=docker.io/qmcgaw/gluetun:latest
          AutoUpdate=registry
          AddCapability=NET_ADMIN
          AddDevice=/dev/net/tun
          EnvironmentFile=${cfg.configPath}/gluetun.env
          Volume=${cfg.dataPath}/gluetun:/gluetun:Z
          HealthCmd=["/gluetun-entrypoint", "healthcheck"]
          Notify=healthy

          [Service]
          Restart=always
        '';
        onChange = ''
          /usr/bin/systemctl --user daemon-reload
          /usr/bin/systemctl --user reload-or-restart gluetun.service
        '';
      };
      "containers/systemd/transmission.container" = {
        text = ''
          [Unit]
          Description=Transmission

          [Container]
          Image=lscr.io/linuxserver/transmission:latest
          AutoUpdate=registry
          Network=gluetun.container
          EnvironmentFile=${cfg.configPath}/transmission.env
          Volume=${cfg.dataPath}/config:/config:Z
          Volume=${cfg.dataPath}/downloads:/downloads:z
          Volume=${cfg.dataPath}/watch:/watch:Z

          [Service]
          Restart=always

          [Install]
          WantedBy=default.target
        '';
        onChange = ''
          /usr/bin/systemctl --user daemon-reload
          /usr/bin/systemctl --user reload-or-restart transmission.service
        '';
      };
    };
  };
}
