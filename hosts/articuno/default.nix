{
  config,
  lib,
  ...
}: {
  flake.nixosConfigurations.articuno = config.flake.lib.nixosSystem {
    modules = [
      {
        imports = [
          ./btrfs.nix
          ./disk-config.nix
          ./hardware-configuration.nix
          # ./howdy.nix
          ./kirov
          ./lanzaboote.nix
          ./nix.nix
          ./nvidia.nix
          ./services
          # mediatek: Add MT6639 (MT7927) Bluetooth firmware
          ({pkgs, ...}: {
            hardware.firmware = [
              (pkgs.runCommand "MT7927" {} ''
                mkdir -p $out/lib/firmware/mediatek

                cp ${pkgs.fetchurl {
                  url = "https://gitlab.com/kernel-firmware/linux-firmware/-/raw/77ad2a92acf2ac3e5ea47432b43d925ff99db909/mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin";
                  hash = "sha256-ZpxcmaDFnIXBKF09G4sxkVwtMTQaIkT07dy/1g/7vHY=";
                }} $out/lib/firmware/mediatek/BT_RAM_CODE_MT6639_2_1_hdr.bin
              '')
            ];
          })
        ];

        networking.hostName = "articuno";
        boot.binfmt.emulatedSystems = ["aarch64-linux"];
        services = {
          xserver.enable = true;
          openssh.enable = lib.mkForce true;
        };
        system.stateVersion = "26.05";
        hardware.ledger.enable = true;
      }
    ];
  };
}
