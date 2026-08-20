{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./rbw.nix
    ./ssh.nix
    ./wezterm.nix
  ];

  wsl = {
    enable = true;
    defaultUser = config.user.username;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
