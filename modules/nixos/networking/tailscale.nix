{
  config,
  lib,
  pkgs,
  ...
}: let
  isWSL = config.wsl.enable or false;
in {
  services.tailscale = {
    enable = lib.mkDefault (! isWSL);
    extraSetFlags = ["--operator=${config.user.username}"];
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
