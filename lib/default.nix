{inputs, ...}: {
  mkNixosSystem = {
    hostname,
    username ? "kirov",
    hostModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs username hostname;
      };

      modules = [../modules/nixos] ++ hostModules;
    };
}
