{...}: {
  local.kirov.home-manager = {
    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          moltres = {
            host = "moltres";
            forwardAgent = true;
          };
          slowpoke = {
            host = "slowpoke";
            forwardAgent = true;
          };
        };
      };
      bw.sshAgent = true;
    };
  };
}
