{internal-lib, ...}:
internal-lib.mkNixosSystem {
  hostname = "slowpoke";
  modules = [./nixos];
}
