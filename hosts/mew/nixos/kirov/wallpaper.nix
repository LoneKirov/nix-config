{
  config,
  lib,
  pkgs,
  ...
}: {
  local.kirov.home-manager.systemd.user = {
    services.dms-random-wallpaper = {
      Unit = {
        Description = "Set random DMS wallpaper";
        After = ["dms.service"];
        ConditionPathExists = "%t/danklinux.path";
      };
      Service = {
        Type = "simple";
        ExecCondition = let
          isUnlocked = pkgs.writeShellScript "is-unlocked.sh" ''
            ${lib.getExe' pkgs.systemd "busctl"} get-property -j org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session LockedHint | ${lib.getExe pkgs.jq} -e '.data | not'
          '';
          isDMSActive = pkgs.writeShellScript "is-dms-active.sh" ''
            ${lib.getExe' pkgs.systemd "systemctl"} --user is-active dms.service
          '';
        in [isDMSActive isUnlocked];
        ExecStart = let
          script =
            pkgs.writeShellApplication
            {
              name = "dms-random-wallpaper";
              runtimeInputs = with pkgs; [findutils dms-shell coreutils-full];
              runtimeEnv = {
                HOME = config.local.kirov.nixos.home;
              };
              text = ''
                wallpaper=$(find $HOME/Pictures/wallpapers -type f | shuf -n 1)
                dms ipc call wallpaper set "$wallpaper"
              '';
            };
        in
          lib.getExe script;
      };
    };
    timers.dms-random-wallpaper = {
      Unit.Description = "dms-random-wallpaper timer";
      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = "15min";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
