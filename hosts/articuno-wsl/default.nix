{
  imports = [
    ./wsl
  ];

  system.stateVersion = "26.05";
  user.hm.services.rbw-agent.enable = true;
}
