{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.users.users.${config.user.username}) home;
in {
  imports = [
    inputs.dms-plugin-registry.nixosModules.default
  ];

  config = lib.mkIf config.host.gui {
    programs = {
      niri.enable = true;

      dms-shell = {
        enable = true;
        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };

        plugins = {
          calculator.enable = true;
          catWidget.enable = true;
          dankLauncherKeys.enable = true;
          niriWindows.enable = true;
          wallpaperCarousel.enable = true;
          nixPackageRunner.enable = true;
          fullscreenPowerMenu.enable = true;
        };
      };

      dsearch = {
        enable = true;

        systemd = {
          enable = true;
          target = "graphical-session.target";
        };
      };
    };

    environment.systemPackages = with pkgs; [dankcalendar];

    services = {
      displayManager = {
        dms-greeter = {
          enable = true;
          compositor.name = config.programs.niri.package.pname;
          # Sync your user's DankMaterialShell theme with the greeter
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

    persist.directories = lib.mkIf config.services.displayManager.dms-greeter.enable [
      "/var/lib/dms-greeter"
    ];
  };
}
