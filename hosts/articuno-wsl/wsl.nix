{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = config.user.username;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  home-manager.users.kirov = {lib, ...}: {
    home.activation.syncWindowsWezterm = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD cp -L -f ${./wezterm.windows.lua} /mnt/c/Users/kirov/.wezterm.lua
    '';
  };
}
