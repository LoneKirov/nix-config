{...}: {
  config = {
    programs.nixvim = {
      enable = true;
      imports = [../../nixvim];
      vimdiffAlias = true;
    };
  };
}
