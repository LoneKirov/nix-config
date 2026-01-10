{lib, ...}: {
  config.programs.nixvim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
    imports = [../../nixvim];
    vimdiffAlias = true;
  };
}
