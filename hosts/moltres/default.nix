{internal-lib, ...}:
internal-lib.mkNixosSystem {
  hostname = "moltres";
  modules = [./nixos];
  authorizedKeys = [(builtins.readFile ../../keys/kirov.pub)];
}
