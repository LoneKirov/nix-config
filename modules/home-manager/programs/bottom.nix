{lib, ...}: {
  config.programs.bottom = {
    enable = lib.mkDefault true;
    settings.flags.battery = true;
  };
}
