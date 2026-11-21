{
  config,
  lib,
  ...
}: {
  services.flatpak.enable = lib.mkDefault config.host.gui;

  # flatpak names the sandbox's zone by matching the /etc/localtime symlink
  # target against $TZDIR. NixOS sets TZDIR to the tzdata store path for systemd
  # units (niri, dms), so apps they launch fail the match, and flatpak falls back
  # to /etc/timezone and then UTC.
  # https://gitlab.alpinelinux.org/alpine/aports/-/issues/14844
  environment.etc.timezone = lib.mkIf (config.services.flatpak.enable && config.time.timeZone != null) {
    text = "${config.time.timeZone}\n";
  };
}
