{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  lanzaboote = config.boot.lanzaboote.enable;
  isWSL = config.host.wsl;
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
        loader.efi.canTouchEfiVariables = true;

        lanzaboote = {
          # lanzaboote measured boot required limiting to 4
          configurationLimit = lib.mkDefault 4;
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

        initrd.systemd.enable = true;
      };

      environment.systemPackages = with pkgs; [
        sbctl
        tpm2-tools
        tpm2-tss
      ];

      persist.directories =
        [
          "/var/lib/sbctl"
        ]
        ++ lib.optionals config.boot.lanzaboote.measuredBoot.enable [
          {
            directory = "/var/lib/pcrlock.d";
            inInitrd = true;
          }
        ];
    })
  ];
}
