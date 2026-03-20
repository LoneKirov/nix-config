{
  config,
  lib,
  ...
}: {
  options.local.programs.steam-flatpak.enable = lib.mkEnableOption "steam-flatpak";

  config = lib.mkIf config.local.programs.steam-flatpak.enable {
    services.flatpak.packages = ["com.valvesoftware.Steam"];
    # https://github.com/junegunn/fzf/issues/4015
    programs.fzf.defaultOptions = ["--walker-skip z:"];
  };
}
