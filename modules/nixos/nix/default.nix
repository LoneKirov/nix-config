{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.determinate.nixosModules.default
    inputs.nix-index-database.nixosModules.default
  ];

  config = let
    flake = "github:LoneKirov/nix-config";
  in {
    nix = {
      settings = {
        # Have nix use xdg
        use-xdg-base-directories = true;
        # optimize the store on every build
        auto-optimise-store = true;
        substituters = ["https://cache.kanto.casa"];
        trusted-public-keys = [(builtins.readFile ../../../keys/harmonia.pub)];
      };
    };
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
    system.autoUpgrade = {
      flake = lib.mkDefault flake;
      dates = lib.mkDefault "daily";
      allowReboot = true;
      randomizedDelaySec = "45min";
    };
    programs = {
      nix-index-database.comma.enable = true;
      nh = {
        enable = true;
        flake = lib.mkDefault (
          if config.user.flakeCheckout != null
          then config.user.flakeCheckout
          else flake
        );
        # deletes old generations, unlike a plain gc; --keep leaves something
        # to roll back to even after weeks without a rebuild
        clean = {
          enable = lib.mkDefault true;
          extraArgs = lib.mkDefault "--keep-since 14d --keep 5";
        };
      };
    };
    environment.systemPackages = with pkgs; [
      dix
      nix-output-monitor
    ];
  };
}
