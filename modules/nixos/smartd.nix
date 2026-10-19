{
  config,
  lib,
  pkgs,
  ...
}: let
  notify = pkgs.writeShellApplication {
    name = "smartd-notify";
    text = ''
      ${lib.getExe config.notify.send} "$SMARTD_SUBJECT" "$SMARTD_FULLMESSAGE"
    '';
  };
in {
  config = lib.mkMerge [
    {
      services.smartd = {
        enable = lib.mkDefault (! config.host.wsl);
        # its -M exec would compete with the one below
        notifications.wall.enable = false;
        # -a warns about pending and uncorrectable sectors, and 5! adds
        # reallocated ones as they grow. Long self-tests run mid-month, away
        # from btrfs's scrub on the 1st
        defaults.monitored = "-a -R 5! -s (S/../.././02|L/../15/./03) -m <nomailer> -M exec ${lib.getExe notify}";
        # saved state stops a warning being sent again after every restart, and
        # lets smartd run a self-test that came due while the host was off
        extraOptions = ["--savestates=/var/lib/smartmontools/smartd."];
      };
    }
    (lib.mkIf config.services.smartd.enable {
      systemd.services.smartd.serviceConfig.StateDirectory = "smartmontools";
      persist.directories = ["/var/lib/smartmontools"];
    })
  ];
}
