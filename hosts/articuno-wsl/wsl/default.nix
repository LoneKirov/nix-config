{config, ...}: {
  imports = [
    ./rbw.nix
    ./ssh.nix
    ./wezterm.nix
  ];

  wsl.defaultUser = config.user.username;

  nixpkgs.hostPlatform = "x86_64-linux";
}
