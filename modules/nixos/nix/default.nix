{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.determinate.nixosModules.default
    inputs.nix-index-database.nixosModules.default
    ./nixremote.nix
  ];

  config = {
    nix = {
      settings = {
        # Enable flakes
        experimental-features = ["nix-command" "flakes"];
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
      flake = "github:LoneKirov/nix-config";
      dates = "daily";
      allowReboot = true;
      randomizedDelaySec = "45min";
      runGarbageCollection = true;
    };
    programs.nix-index-database.comma.enable = true;
    environment.systemPackages = with pkgs; [dix nix-output-monitor];
  };
}
