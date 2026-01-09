{inputs, ...}: {
  mkNixosSystem = {
    hostname,
    user,
    hostModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [../modules/nixos] ++ hostModules;
    };
}
