{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  lanzaboote = config.boot.lanzaboote.enable;
  isWSL = config.wsl.enable or false;
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = lib.mkMerge [
    (lib.mkIf (! isWSL) {
      boot = {
        lanzaboote.enable = lib.mkDefault true;
        # lanzaboote handles systemd-boot if enabled
        loader.systemd-boot.enable = lib.mkDefault (! lanzaboote);
      };
    })
    (lib.mkIf lanzaboote {
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
            pcrs = [
              0 # platform-code
              1 # platform-config
              2 # external-code
              3 # external-config
              4 # boot-loader-code
              7 # secure-boot-policy
            ];
          };
          bootCounting.initialTries = 3;
        };

        # Enable systemd within initrd
        initrd.systemd.enable = true;
      };

      environment.systemPackages = with pkgs; [
        sbctl
        tpm2-tools
        tpm2-tss
      ];
    })
  ];
}
