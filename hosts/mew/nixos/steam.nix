{...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    protontricks.enable = true;
  };
  # https://github.com/junegunn/fzf/issues/4015
  home-manager.users.kirov.programs.fzf.defaultOptions = ["--walker-skip z:"];
}
