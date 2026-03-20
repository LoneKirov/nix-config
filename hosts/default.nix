{internal-lib, ...}: {
  config.flake = {
    nixosConfigurations = {
      articuno = import ./articuno {inherit internal-lib;};
      mew = import ./mew {inherit internal-lib;};
      moltres = import ./moltres {inherit internal-lib;};
      slowpoke = import ./slowpoke {inherit internal-lib;};
    };
  };
}
