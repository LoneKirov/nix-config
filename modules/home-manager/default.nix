{lib, ...}: {
  imports = [
    ./fonts.nix
    ./programs
  ];

  options = {
    programs = {
      niri.enable = lib.mkEnableOption "niri";
      dms-shell.enable = lib.mkEnableOption "dms-shell";
    };
    services = {
      xserver.enable = lib.mkEnableOption "xserver";
    };
  };

  config = {
    xdg.enable = true;
  };
}
