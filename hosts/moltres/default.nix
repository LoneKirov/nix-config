{internal-lib, ...}:
internal-lib.mkNixosSystem {
  hostname = "moltres";
  modules = [./nixos];
}
