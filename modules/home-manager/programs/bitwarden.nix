{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  xserver = osConfig.services.xserver.enable or false;
  bw = config.programs.bw;
in {
  options.programs.bw = {
    enable = lib.mkEnableOption "bw";
    sshAgent = lib.mkEnableOption "sshAgent";
  };

  config = {
    programs = {
      bw.enable = lib.mkDefault true;

      rbw = {
        enable = bw.enable;
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
    home = lib.mkIf bw.enable {
      packages = with pkgs; [
        bitwarden-cli
      ];
      sessionVariables = lib.mkIf bw.sshAgent {
        SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
      };
    };
    systemd.user.sessionVariables = lib.mkIf bw.sshAgent {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
    };
  };
}
