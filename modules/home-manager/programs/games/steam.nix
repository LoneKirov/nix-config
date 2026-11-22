{
  config,
  lib,
  ...
}: {
  options.programs.steam-flatpak.enable = lib.mkEnableOption "steam-flatpak";

  config = lib.mkIf config.programs.steam-flatpak.enable {
    services.flatpak = {
      packages = ["com.valvesoftware.Steam"];
      overrides."com.valvesoftware.Steam".Context.filesystems = [config.games.directory];
    };
    # https://github.com/junegunn/fzf/issues/4015
    programs.fzf.defaultOptions = ["--walker-skip z:"];
  };
}
