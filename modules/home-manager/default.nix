{lib, ...}: {
  imports = [
    ./fonts.nix
    ./programs
    ./theme.nix
  ];

  options.local = {
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
