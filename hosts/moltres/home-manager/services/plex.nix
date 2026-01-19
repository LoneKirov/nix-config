{ config, lib, ... }:

let
  cfg = config.services.plex;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.services.plex = {
    enable = mkEnableOption "plex";
    dataPath = mkOption {
      type = types.path;
      default = "${config.xdg.stateHome}/plex";
      apply = toString;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "containers/systemd/plex.container" = {
        text = ''
          [Unit]
          Description=Plex

          [Container]
          Image=lscr.io/linuxserver/plex:latest
          AutoUpdate=registry
          Network=host
          UserNS=keep-id
          GroupAdd=keep-groups
          Environment=TZ=America/Los_Angeles
          Environment=ALLOWED_NETWORKS=10.0.1.0/24
          ShmSize=6G
          Volume=${cfg.dataPath}/config:/config:Z
          Tmpfs=/transcode:size=10G
          Volume=${cfg.dataPath}/optimized:/optimized:Z
          Volume=${cfg.dataPath}/media:/data/media:ro,Z
          Volume=${config.xdg.stateHome}/resilio-sync/folders/Patreon:/data/patreon:ro,z
          Volume=${config.xdg.stateHome}/torrents/downloads/complete:/data/torrents:ro,z
          AddDevice=/dev/dri

          [Service]
          TimeoutStartSec=900
          Restart=always

          [Install]
          WantedBy=default.target
        '';
        onChange = ''
          /usr/bin/systemctl --user daemon-reload
          /usr/bin/systemctl --user reload-or-restart plex.service
        '';
      };
    };
  };
}
