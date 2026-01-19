{internal-lib, ...}:
internal-lib.mkNixosSystem {
  hostname = "mew";
  modules = [./nixos];
}
