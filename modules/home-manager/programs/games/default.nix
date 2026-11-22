{
  config,
  lib,
  ...
}: {
  imports = [
    ./faugus.nix
    ./steam.nix
  ];

  options.games.directory = lib.mkOption {
    type = lib.types.str;
    default = "${config.xdg.stateHome}/games";
    description = ''
      Games installed outside a store, with Faugus's Wine prefixes under
      `prefixes/`, so copying the folder to another host carries each game's
      saves wherever the game writes them.
    '';
  };
}
