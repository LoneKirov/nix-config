{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [xwayland-satellite];
    services.flatpak = {
      enable = true;
      packages = ["com.discordapp.Discord"];
      update.auto.enable = true;
    };
    # https://github.com/gmodena/nix-flatpak/issues/31
    xdg.systemDirs.data = ["$HOME/.local/share/flatpak/exports/share"];
  };
}
