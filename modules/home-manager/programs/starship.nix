{
  config,
  lib,
  ...
}: {
  config.programs.starship = lib.mkMerge [
    {enable = lib.mkDefault true;}
    (lib.mkIf config.programs.starship.enable {
      presets = ["nerd-font-symbols"];
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        direnv.disabled = false;
        hostname.ssh_only = config.local.services.xserver.enable;
      };
    })
  ];
}
