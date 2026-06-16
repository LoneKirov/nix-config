{config, ...}: {
  config.flake = {
    nixosConfigurations = {
      articuno = import ./articuno {inherit config;};
      mew = import ./mew {inherit config;};
      moltres = import ./moltres {inherit config;};
      slowpoke = import ./slowpoke {inherit config;};
    };
  };
}
