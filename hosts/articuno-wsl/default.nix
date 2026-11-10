{
  imports = [
    ./wsl
  ];

  system.stateVersion = "26.11";
  user.hm.services.rbw-agent.enable = true;
}
