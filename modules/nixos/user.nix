{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      useUserPackages = true;
      useGlobalPkgs = true;
    };

    local.user = {
      nixos = {
        uid = 1000;
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel" # sudo
          "dialout" # serial devices
        ];
      };

      home-manager = {...}: {
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
