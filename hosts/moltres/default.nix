{config, ...}: {
  flake.nixosConfigurations.moltres = config.flake.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./btrfs.nix
          ./disk-config.nix
          ./hardware-configuration.nix
          ./kirov
          ./lanzaboote.nix
          ./services
        ];

        networking.hostName = "moltres";
        boot.binfmt.emulatedSystems = ["aarch64-linux"];
        services.xserver.enable = false;
        networking.firewall.enable = false;
        system = {
          autoUpgrade.enable = true;
          stateVersion = "26.05";
        };
        users.users.nixremote.openssh.authorizedKeys.keys = [(builtins.readFile ../../keys/github.pub)];
      }
    ];
  };
}
