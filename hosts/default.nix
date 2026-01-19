{
  internal-lib,
  withSystem,
  ...
}: {
  config.flake = {
    nixosConfigurations = {
      mew = import ./mew {inherit internal-lib;};
    };
    homeConfigurations = {
      "kirov@moltres" = import ./moltres {inherit internal-lib withSystem;};
      "kirov@gateway" = import ./gateway {inherit internal-lib withSystem;};
    };
  };
}
