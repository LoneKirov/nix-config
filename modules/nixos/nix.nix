{
  config,
  inputs,
  lib,
  pkgs,
  authorizedKeys,
  ...
}: {
  imports = [
    inputs.determinate.nixosModules.default
    inputs.nix-index-database.nixosModules.default
  ];

  config = lib.mkMerge [
    {
      nix = {
        settings = {
          # Enable flakes
          experimental-features = ["nix-command" "flakes"];
          # Have nix use xdg
          use-xdg-base-directories = true;
          # optimize the store on every build
          auto-optimise-store = true;
        };
      };
    }
    (lib.mkIf (! config.services.xserver.enable)
      (let
        nixremote = "nixremote";
      in {
        users = {
          users.${nixremote} = {
            isSystemUser = true;
            home = "/var/lib/${nixremote}";
            group = nixremote;
            extraGroups = ["wheel"];
            shell = "${lib.getExe' pkgs.bash "bash"}";

            openssh.authorizedKeys.keys = authorizedKeys;
          };
          groups.${nixremote} = {};
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/${nixremote} 0750 ${nixremote} ${nixremote}"
          "d /var/lib/${nixremote}/.ssh 0700 ${nixremote} ${nixremote}"
        ];

        nix.settings.trusted-users = [nixremote];
      }))
  ];
}
