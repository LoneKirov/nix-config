{
  config,
  lib,
  ...
}: {
  config = {
    programs.starship = lib.mkMerge [
      {enable = lib.mkDefault true;}
      (lib.mkIf config.programs.starship.enable {
        settings = {
          "$schema" = "https://starship.rs/config-schema.json";
        };
      })
    ];
  };
}
