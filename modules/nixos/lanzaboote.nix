{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = lib.mkMerge [
    {
      boot = {
        lanzaboote.enable = lib.mkDefault true;
        # lanzaboote handles systemd-boot if enabled
        loader.systemd-boot.enable = ! config.boot.lanzaboote.enable;
      };
    }
    (lib.mkIf config.boot.lanzaboote.enable {
      boot = {
        loader = {
          efi.canTouchEfiVariables = true;
          # lanzaboote measured boot required limiting to 8
          systemd-boot.configurationLimit = lib.mkForce 8;
        };

        # Setup Lanzaboote for SecureBoot
        lanzaboote = {
          # Using sbctl for key generation and management
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
          measuredBoot = {
            enable = true;
            pcrs = [0 1 2 3 4 7];
          };
        };

        # Enable systemd within initrd
        initrd.systemd.enable = true;
      };

      environment.systemPackages = with pkgs; [
        sbctl
      ];
    })
  ];
}
