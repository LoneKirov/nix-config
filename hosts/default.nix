{internal-lib, ...}: {
  config.flake = {
    nixosConfigurations = {
      mew = import ./mew {inherit internal-lib;};
      moltres = import ./moltres {inherit internal-lib;};
      slowpoke = import ./slowpoke {inherit internal-lib;};
    };
  };
}
