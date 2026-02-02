{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

  config = lib.mkIf config.services.flatpak.enable {
    services.flatpak = {
      packages = ["com.github.tchx84.Flatseal"];
      update.auto.enable = true;
    };
    # https://github.com/gmodena/nix-flatpak/issues/31
    xdg.systemDirs.data = ["$HOME/.local/share/flatpak/exports/share"];
  };
}
