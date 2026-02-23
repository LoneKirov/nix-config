{
  config,
  pkgs,
  inputs,
  username,
  authorizedKeys,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    users.users.${username} = {
      uid = 1000;
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel" # sudo
        "dialout" # serial devices
      ];
      openssh.authorizedKeys.keys = authorizedKeys;
    };
    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${username} = {...}: {
        imports = [
          {
            programs = {
              niri.enable = config.programs.niri.enable;
              dms-shell.enable = config.programs.dms-shell.enable;
            };
            services.xserver.enable = config.services.xserver.enable;
          }
          ../home-manager
        ];

        home.stateVersion = config.system.stateVersion;
      };
    };

    programs = {
      zsh.enable = true;
    };
  };
}
