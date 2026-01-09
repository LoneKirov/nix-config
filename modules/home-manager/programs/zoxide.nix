{
  config,
  lib,
  ...
}: {
  config.programs.zoxide = lib.mkMerge [
    {enable = lib.mkDefault true;}
    (lib.mkIf config.programs.zoxide.enable {
      options = ["--cmd cd"];
    })
  ];
}
