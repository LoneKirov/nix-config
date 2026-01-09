{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    users.users.${username} = {
      isNormalUser = true;
      hashedPasswordFile = "/persistent/etc/passwords/${username}"; # impermanence means /etc/shadow isn't persisted
      shell = pkgs.zsh;
      extraGroups = ["wheel"];
    };
    home-manager = {
      sharedModules = with inputs; [
        nixvim.homeModules.nixvim
        nix-flatpak.homeManagerModules.nix-flatpak
      ];
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${username} = {pkgs, ...}: {
        imports = [
          ../home-manager
        ];

        xdg.enable = true;
        home = {
          packages = with pkgs; [
            nerd-fonts.fira-code
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
          ];
          stateVersion = config.system.stateVersion;
        };
        fonts.fontconfig.enable = true;
      };
    };

    programs = {
      zsh.enable = true;
    };
  };
}
