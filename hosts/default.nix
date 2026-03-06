{
  internal-lib,
  # withSystem,
  ...
}: {
  config.flake = {
    nixosConfigurations = {
      mew = import ./mew {inherit internal-lib;};
      moltres = import ./moltres {inherit internal-lib;};
    };
    # homeConfigurations = {
    #   "kirov@gateway" = import ./gateway {inherit internal-lib withSystem;};
    # };
  };
}
