{
  inputs,
  internal-lib,
  ...
}: let
  inherit (inputs) nixpkgs nixos-hardware;
in {
  flake.nixosConfigurations.mew = internal-lib.mkNixosSystem {
    hostname = "mew";
    user = "kirov";
    hostModules = [./nixos];
  };
}
