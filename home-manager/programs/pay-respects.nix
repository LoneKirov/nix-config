{
  config,
  lib,
  ...
}: {
  config = {
    programs.pay-respects = lib.mkMerge [
      {enable = lib.mkDefault true;}
      (lib.mkIf config.programs.pay-respects.enable {
        options = [
          "--alias"
          "fuck"
        ];
      })
    ];
  };
}
