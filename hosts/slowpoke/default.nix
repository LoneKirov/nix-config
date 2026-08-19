{
  config,
  lib,
  ...
}: {
  flake.nixosConfigurations.slowpoke = config.flake.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./btrfs.nix
          ./disk-config.nix
          ./hardware-configuration.nix
          ./kirov
          ./nix.nix
          ./raspberry-pi-3
          ./services
          ./tailscale.nix
        ];

        networking.hostName = "slowpoke";
        services.xserver.enable = false;
        networking.firewall.enable = false;
        boot.loader.systemd-boot.configurationLimit = 4;
        system = {
          autoUpgrade = {
            enable = true;
            # don't want to run at the same time as moltres
            dates = lib.mkForce "*-*-* 04:00:00";
          };
          stateVersion = "26.05";
        };
      }
    ];
  };
}
