{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  xserver = osConfig.services.xserver.enable or false;
  rbw = config.programs.rbw;
  rbw-agent = config.services.rbw-agent;
in {
  options.services.rbw-agent.enable = lib.mkEnableOption "rbw-agent";

  config = lib.mkMerge [
    {
      programs.rbw.enable = lib.mkDefault true;
    }
    (lib.mkIf rbw.enable {
      programs = {
        rbw = {
          # workaround for email being required in HM settings
          package = pkgs.symlinkJoin {
            name = "rbw-wrapped";
            paths = let
              pinentry =
                if xserver
                then lib.getExe pkgs.pinentry-gnome3
                else lib.getExe pkgs.pinentry-curses;
            in [
              (pkgs.writeShellScriptBin "pinentry" ''${pinentry} "$@"'')
              pkgs.rbw
            ];
          };
        };
      };
      home.packages = with pkgs; [
        bitwarden-cli
      ];
    })
    (lib.mkIf rbw-agent.enable {
      systemd.user.services.rbw-agent = {
        Install.WantedBy = ["default.target"];
        Unit = {
          Description = "rbw SSH agent";
        };
        Service = {
          ExecStart = lib.getExe' rbw.package "rbw-agent";
          Restart = "on-failure";
          PIDFile = "rbw/pidfile";
          Type = "forking";
        };
      };
      sshAuthSock = {
        enable = true;
        initialization = {
          bash = ''export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"'';
          fish = ''set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"'';
          nushell = ''$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/rbw/ssh-agent-socket"'';
        };
        systemd.socketProviderUnit = "rbw-agent.service";
      };
    })
  ];
}
