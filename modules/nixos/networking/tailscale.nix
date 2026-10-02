{
  config,
  lib,
  pkgs,
  ...
}: let
  isWSL = config.host.wsl;
in {
  config = lib.mkMerge [
    {
      services.tailscale.enable = lib.mkDefault (! isWSL);
    }
    (lib.mkIf config.services.tailscale.enable {
      # only desktops need to manage tailscale without sudo; an empty value
      # clears the operator tailscaled has persisted
      services.tailscale.extraSetFlags = ["--operator=${lib.optionalString config.host.gui config.user.username}"];
      persist.directories = [
        "/var/lib/tailscale" # tailscale state
      ];
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
    })
  ];
}
