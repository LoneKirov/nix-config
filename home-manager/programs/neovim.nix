{...}: {
  config = {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      imports = [../../nixvim];
      vimdiffAlias = true;
    };
  };
}
