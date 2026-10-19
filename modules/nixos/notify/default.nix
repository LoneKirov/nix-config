{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.notify;
  inherit (config.networking) hostName;

  discordSend = pkgs.writeShellApplication {
    name = "discord-send";
    runtimeInputs = [pkgs.curl pkgs.jq];
    text = ''
      if [[ $# -ne 2 ]]; then
        echo "usage: discord-send TITLE MESSAGE" >&2
        exit 2
      fi
      # Discord rejects messages over 2000 characters
      jq -n --arg title "$1" --arg message "$2" '{content: ("**\($title)**\n\($message)")[:2000]}' |
        curl -fsS -m 10 --retry 5 -o /dev/null -H "Content-Type: application/json" --data-binary @- \
          "$(< ${config.sops.secrets.discord-webhook.path})"
    '';
  };

  ping = pkgs.writeShellApplication {
    name = "healthchecks-ping";
    runtimeInputs = [pkgs.curl];
    text = ''
      key=$(< "$CREDENTIALS_DIRECTORY/healthchecks")
      # create=1 adds the check on its first ping, so a new host only needs its
      # period and grace time set on healthchecks.io
      curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$key/$1?create=1"
    '';
  };
in {
  options.notify = {
    send = lib.mkOption {
      type = lib.types.package;
      default = discordSend;
      readOnly = true;
      description = "`discord-send TITLE MESSAGE` posts to the Discord webhook in notify.sops.yaml. Only root can read the webhook.";
    };
    healthchecks = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {btrbk-btrbk = "btrbk";};
      description = "systemd services that ping healthchecks.io after each successful run, mapped to a check name. The check is `<host>-<name>`, created on its first ping.";
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = [cfg.send];
      sops.secrets.discord-webhook = {
        sopsFile = ./notify.sops.yaml;
        key = "discord_webhook";
      };
    }
    (lib.mkIf (cfg.healthchecks != {}) {
      sops.secrets.healthchecks-ping-key = {
        sopsFile = ./notify.sops.yaml;
        key = "healthchecks_ping_key";
      };
      systemd.services =
        lib.mapAttrs (_: check: {
          serviceConfig = {
            LoadCredential = ["healthchecks:${config.sops.secrets.healthchecks-ping-key.path}"];
            # last, so a ping means the service's own post-start steps passed too.
            # An unreachable healthchecks.io mustn't fail a run that succeeded
            ExecStartPost = lib.mkAfter ["-${lib.getExe ping} ${hostName}-${check}"];
          };
        })
        cfg.healthchecks;
    })
  ];
}
