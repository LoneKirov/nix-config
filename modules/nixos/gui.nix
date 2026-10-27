{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.users.users.${config.user.username}) home;
  registry = inputs.dux-plugin-registry.packages.${pkgs.stdenv.hostPlatform.system};
in {
  config = lib.mkIf config.host.gui {
    programs = {
      niri.enable = true;

      dux-shell = {
        enable = true;
        systemd = {
          enable = true;
          restartIfChanged = true;
        };

        # the registry's nixosModule only fills in src under the old
        # programs.dms-shell name, which is now an alias without suboptions
        plugins = lib.genAttrs [
          "calculator"
          "catWidget"
          "dankLauncherKeys"
          "niriWindows"
          "wallpaperCarousel"
          "nixPackageRunner"
        ] (name: {src = registry.${name};});
      };

      dux-search = {
        enable = true;

        systemd = {
          enable = true;
          target = "graphical-session.target";
        };
      };
    };

    environment.systemPackages = with pkgs; [dux-calendar];

    services = {
      displayManager = {
        dux-greeter = {
          enable = true;
          compositor.name = config.programs.niri.package.pname;
          # Sync your user's Dux Shell theme with the greeter
          configHome = home;
        };
      };

      # dms uses upower for battery stats
      upower.enable = true;
    };

    # initial login via biometric requires entering password later to unlock user keychain
    security.pam.services.login = {
      fprintAuth = false;
      howdy.enable = false;
    };

    location.provider = "geoclue2";

    persist.directories = lib.mkIf config.services.displayManager.dux-greeter.enable [
      "/var/lib/dms-greeter"
    ];
  };
}
