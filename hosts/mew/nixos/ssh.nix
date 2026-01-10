{...}: {
  home-manager.users.kirov.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      moltres = {
        host = "moltres";
        forwardAgent = true;
      };
      zapdos = {
        host = "zapdos";
        forwardAgent = true;
      };
    };
  };
}
