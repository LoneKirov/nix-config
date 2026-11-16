{
  config,
  lib,
  ...
}: {
  options.programs.signal-flatpak.enable = lib.mkEnableOption "signal-flatpak" // {default = config.host.gui;};

  config = lib.mkIf config.programs.signal-flatpak.enable {
    services.flatpak = {
      packages = ["org.signal.Signal"];
      # The flatpak defaults to the basic store, which writes the database key
      # to config.json in plaintext. NixOS's niri module turns on gnome-keyring.
      # https://github.com/flathub/org.signal.Signal#options
      overrides."org.signal.Signal".Environment.SIGNAL_PASSWORD_STORE = "gnome-libsecret";
    };
  };
}
