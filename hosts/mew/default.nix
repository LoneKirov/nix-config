{internal-lib, ...}: {
  flake.nixosConfigurations.mew = internal-lib.mkNixosSystem {
    hostname = "mew";
    modules = [./nixos];
  };
}
