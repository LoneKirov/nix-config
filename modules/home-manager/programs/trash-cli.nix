{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.trash-cli.enable = lib.mkEnableOption "trash-cli" // {default = true;};

  config = lib.mkIf config.programs.trash-cli.enable {
    home.packages = with pkgs; [trash-cli];
  };
}
