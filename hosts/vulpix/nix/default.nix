{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.determinate.darwinModules.default
    inputs.nix-index-database.darwinModules.default
    ./nixremote.nix
  ];

  config = {
    determinateNix = {
      customSettings = {
        # Enable flakes
        experimental-features = ["nix-command" "flakes"];
        # optimize the store on every build
        auto-optimise-store = true;
        extra-substituters = lib.mkAfter ["https://cache.kanto.casa"];
        extra-trusted-public-keys = lib.mkAfter [(builtins.readFile ../../../keys/harmonia.pub)];
      };
    };
    programs.nix-index-database.comma.enable = true;
    environment.systemPackages = with pkgs; [dix nix-output-monitor];
  };
}
