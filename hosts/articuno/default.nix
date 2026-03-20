{internal-lib, ...}:
internal-lib.mkNixosSystem {
  hostname = "articuno";
  modules = [./nixos];
}
