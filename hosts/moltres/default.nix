{internal-lib, ...}:
internal-lib.mkNixosSystem {
  hostname = "moltres";
  modules = [./nixos];
  authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUlo/XEzK3peTjqKEwvRAHBc4vzCJNXbfxpceUxQ2KA"];
}
