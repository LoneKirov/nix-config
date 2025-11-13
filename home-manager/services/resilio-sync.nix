{
  config,
  lib,
  ...
}: let
  cfg = config.services.resilio-sync;
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.services.resilio-sync = {
    enable = mkEnableOption "resilio sync";
    dataPath = mkOption {
      type = types.path;
      default = "${config.xdg.stateHome}/resilio-sync";
      apply = toString;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "containers/systemd/resilio-sync.container" = {
        text = ''
          [Unit]
          Description=Resilio Sync

          [Container]
          Image=lscr.io/linuxserver/resilio-sync
          AutoUpdate=registry
          Network=caddy.network
          Environment=PUID=0
          Environment=PGID=0
          Environment=TZ=America/Los_Angeles
          Volume=${cfg.dataPath}/config:/config:Z
          Volume=${cfg.dataPath}/downloads:/downloads:Z
          Volume=${cfg.dataPath}/folders:/sync:z

          [Service]
          TimeoutStartSec=900
          Restart=always

          [Install]
          WantedBy=default.target
        '';
        onChange = ''
          /usr/bin/systemctl --user daemon-reload
          /usr/bin/systemctl --user reload-or-restart resilio-sync.service
        '';
      };
    };
  };
}
