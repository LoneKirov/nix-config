{
  config,
  lib,
  pkgs,
  ...
}: let
  gui = config.host.gui;
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
              gnome3 = lib.getExe pkgs.pinentry-gnome3;
              curses = lib.getExe pkgs.pinentry-curses;
              # rbw-agent runs pinentry with the display variables of the rbw
              # command that asked for the password, and ssh-agent requests
              # reuse the last command's. pinentry-gnome3 ignores them and
              # prompts on the desktop whenever it can reach the session bus,
              # which pam_systemd also gives ssh logins, so a client without a
              # local display gets the curses prompt on its own terminal. X
              # forwarding sets DISPLAY to host:N, never :N.
              pinentry =
                if gui
                then ''
                  if [ -n "''${WAYLAND_DISPLAY-}" ]; then
                    exec ${gnome3} "$@"
                  fi
                  case "''${DISPLAY-}" in
                    :*) exec ${gnome3} "$@" ;;
                  esac
                  exec ${curses} "$@"
                ''
                else ''exec ${curses} "$@"'';
            in [
              (pkgs.writeShellScriptBin "pinentry" pinentry)
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
