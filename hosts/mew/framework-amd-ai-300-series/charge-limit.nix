_: let
  threshold = "/sys/class/power_supply/BAT1/charge_control_end_threshold";
  state = "/var/lib/battery-charge-limit/end-threshold";
  save = ''
    limit=$(cat ${threshold})
    echo "$limit" > ${state}
  '';
  restore = ''
    if [ -f ${state} ]; then
      cat ${state} > ${threshold}
    fi
  '';
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    StateDirectory = "battery-charge-limit";
  };
in {
  # the firmware resets the charge limit whenever the laptop powers off, which
  # includes hibernate, so keep whatever was last applied (e.g. from DMS)
  systemd.services = {
    # restore at boot and save at shutdown, like systemd-backlight
    battery-charge-limit = {
      description = "Restore and save the battery charge limit";
      wantedBy = ["multi-user.target"];
      script = restore;
      preStop = save;
      inherit serviceConfig;
    };
    # save before sleep and restore after resume, like NixOS's sleep-actions
    battery-charge-limit-sleep = {
      description = "Keep the battery charge limit across sleep";
      wantedBy = ["sleep.target"];
      before = ["sleep.target"];
      unitConfig.StopWhenUnneeded = true;
      script = save;
      preStop = restore;
      inherit serviceConfig;
    };
  };

  persist.directories = ["/var/lib/battery-charge-limit"];
}
