{
  config,
  lib,
  ...
}: {
  options.programs.spotify-flatpak.enable = lib.mkEnableOption "spotify-flatpak";

  config = lib.mkIf config.programs.spotify-flatpak.enable {
    services.flatpak.packages = ["com.spotify.Client"];
  };
}
