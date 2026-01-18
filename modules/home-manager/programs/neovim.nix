{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixvim.homeModules.nixvim];

  config.programs.nixvim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
    imports = [../../nixvim];
    vimdiffAlias = true;
  };
}
