{
  config,
  lib,
  pkgs,
  ...
}: let
  jq = lib.getExe pkgs.jq;
in {
  options.programs.faugus-flatpak.enable = lib.mkEnableOption "faugus-flatpak";

  config = lib.mkIf config.programs.faugus-flatpak.enable {
    # The flatpak can already reach all of home, so unlike Steam it needs no
    # override for the games folder.
    services.flatpak.packages = ["io.github.Faugus.faugus-launcher"];

    # Faugus fills in a new game's prefix as <default-prefix>/<title>, so the
    # default has to be in the games folder for the prefix, and the saves in
    # it, to travel with the games. Faugus rewrites config.json itself, so
    # only this key is set.
    home.activation.faugusDefaultPrefix = lib.hm.dag.entryAfter ["writeBoundary"] ''
      faugusConfig=${lib.escapeShellArg "${config.home.homeDirectory}/.var/app/io.github.Faugus.faugus-launcher/config/faugus-launcher/config.json"}
      faugusPrefixes=${lib.escapeShellArg "${config.games.directory}/prefixes"}
      if [ ! -e "$faugusConfig" ]; then
        run mkdir -p "$(dirname "$faugusConfig")"
        ${jq} -n --arg p "$faugusPrefixes" '{"default-prefix": $p}' | run tee "$faugusConfig" > /dev/null
      elif faugusCurrent=$(${jq} -r '."default-prefix"' "$faugusConfig") && [ "$faugusCurrent" != "$faugusPrefixes" ]; then
        faugusNew=$(${jq} --arg p "$faugusPrefixes" '."default-prefix" = $p' "$faugusConfig")
        printf '%s\n' "$faugusNew" | run tee "$faugusConfig" > /dev/null
      fi
    '';
  };
}
