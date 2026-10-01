{
  config,
  inputs,
  ...
}: {
  imports = [inputs.nixvim.flakeModules.default];

  nixvim = {
    packages.enable = true;
    checks.enable = true;
  };

  perSystem = {system, ...}: {
    nixvimConfigurations.nvim = config.flake.lib.evalNixvim {inherit system;};
  };
}
