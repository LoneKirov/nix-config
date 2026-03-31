{
  config,
  lib,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    extraSetFlags = ["--operator=${config.local.user.nixos.name}"];
  };
  systemd.services."tailscale-restart-on-resume" = {
    description = "Restart Tailscale after resuming";
    after = ["suspend.target" "suspend-then-hibernate.target" "hibernate.target"];
    wantedBy = ["suspend.target" "suspend-then-hibernate.target" "hibernate.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = "${lib.getExe' pkgs.systemd "systemctl"} is-active tailscaled.service";
      ExecStart = "${lib.getExe' pkgs.systemd "systemctl"} --no-block restart tailscaled.service";
    };
  };
}
