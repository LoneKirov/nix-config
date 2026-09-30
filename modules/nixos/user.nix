{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.user;
  inherit (cfg) username;
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
      passwordSopsFile = lib.mkOption {
        type = types.path;
        description = "Sops file holding the user's hashed password under the `hashed` key.";
      };
      hm = lib.mkOption {
        type = types.deferredModule;
        default = {};
        description = "Home-manager configuration for the user.";
      };
      flakeCheckout = lib.mkOption {
        type = types.nullOr types.str;
        default =
          if config.host.gui || config.host.wsl
          then "${config.home-manager.users.${username}.xdg.configHome}/nix-config"
          else null;
        description = "Local checkout of this flake, or null if the host has none.";
      };
    };
  };

  config = {
    sops.secrets.user_hashed_password = {
      format = "yaml";
      sopsFile = cfg.passwordSopsFile;
      key = "hashed";
      neededForUsers = true;
    };

    users.users.${username} = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [
        "wheel" # sudo
        "dialout" # serial devices
      ];
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets.user_hashed_password.path;
      openssh.authorizedKeys.keys = lib.mkIf config.host.ssh [cfg.sshKey];
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${username} = {
        imports = [
          ../home-manager
          cfg.hm
        ];

        home.stateVersion = config.system.stateVersion;
      };
    };
  };
}
