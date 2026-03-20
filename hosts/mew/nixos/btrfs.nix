{
  config,
  lib,
  pkgs,
  ...
}: {
  services.btrbk.instances.btrbk.settings = {
    subvolume."${config.local.impermanence.persistentMountpoint}" = {
      target."ssh://moltres/srv/backup/mew/persistent" = {};
    };
    subvolume."/home" = {
      target."ssh://moltres/srv/backup/mew/home" = {};
    };
  };
  systemd.services."btrbk-btrbk".serviceConfig.ExecStart = lib.mkForce (pkgs.writeShellScript "btrbk-metered.sh" ''
    ${lib.getExe pkgs.btrbk} -c /etc/btrbk/btrbk.conf snapshot
    metered_status=$(${lib.getExe' pkgs.systemd "busctl"} -j get-property \
             org.freedesktop.NetworkManager /org/freedesktop/NetworkManager \
             org.freedesktop.NetworkManager Metered | ${lib.getExe pkgs.jq} ".data")
    # 1 is yes, 3 is guess_yes
    if [[ ! $metered_status =~ (1|3) ]]; then
      ${lib.getExe pkgs.btrbk} -c /etc/btrbk/btrbk.conf resume
    fi
  '');
}
