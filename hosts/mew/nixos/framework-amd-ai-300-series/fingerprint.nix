{
  lib,
  pkgs,
  ...
}: {
  # https://community.frame.work/t/only-enable-fingerprint-authentication-when-lid-is-open/21544/8
  systemd.services.fprintd.preStart = ''
    ${lib.getExe' pkgs.gnugrep "grep"} -q open /proc/acpi/button/lid/LID0/state
  '';
}
