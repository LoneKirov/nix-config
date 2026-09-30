{config, ...}: {
  programs.nh.flake = "${config.home-manager.users.kirov.xdg.configHome}/nix-config";
}
