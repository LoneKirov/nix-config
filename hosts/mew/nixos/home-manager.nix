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
    users = {
      users.kirov = {
        isNormalUser = true;
        hashedPasswordFile = "/persistent/etc/passwords/kirov"; # impermanence means /etc/shadow isn't persisted
        shell = pkgs.zsh;
        extraGroups = ["wheel"];
      };
    };
    home-manager = {
      sharedModules = with inputs; [
        nixvim.homeModules.nixvim
        nix-flatpak.homeManagerModules.nix-flatpak
      ];
      useUserPackages = true;
      useGlobalPkgs = true;

      users.kirov = {pkgs, ...}: {
        imports = [
          ../../../home-manager/shells/zsh.nix
          ../../../home-manager/programs
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
