{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config.user) username;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options = let
    inherit (lib) types;
  in {
    user = {
      username = lib.mkOption {
        type = types.nonEmptyStr;
        default = "kirov";
      };
      sshKey = lib.mkOption {
        type = types.nonEmptyStr;
        default = builtins.readFile ../../keys/kirov.pub;
      };
    };
  };

  config = {
    users.users.${username} = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [
        "wheel" # sudo
        "dialout" # serial devices
      ];
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${username} = {...}: {
        imports = [../home-manager];

        home.stateVersion = config.system.stateVersion;
      };
    };
  };
}
