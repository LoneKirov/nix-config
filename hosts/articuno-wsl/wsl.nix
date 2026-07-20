{
  config,
  inputs,
  pkgs,
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

  programs.fuse.enable = true;
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  home-manager.users.kirov = {
    config,
    lib,
    ...
  }: {
    home.activation = lib.mkIf config.programs.wezterm.enable {
      syncWindowsWezterm = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD cp -L -f ${config.xdg.configHome}/wezterm/wezterm.lua /mnt/c/Users/kirov/.wezterm.lua
      '';
    };
  };
}
