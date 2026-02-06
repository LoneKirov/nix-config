{
  config,
  inputs,
  lib,
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
      {
        users = {
          users.nixremote = {
            isNormalUser = true;
            home = "/tmp/nixremote";
            group = "nixremote";
            extraGroups = ["wheel"];
            useDefaultShell = true;

            openssh.authorizedKeys.keys = authorizedKeys;
          };
          groups.nixremote = {};
        };

        nix.settings.trusted-users = ["nixremote"];
      })
  ];
}
