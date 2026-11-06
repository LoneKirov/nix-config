{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.dgop.enable = lib.mkEnableOption "dgop" // {default = true;};

  config = lib.mkIf config.programs.dgop.enable {
    home.packages = with pkgs; [dux-gop];
  };
}
