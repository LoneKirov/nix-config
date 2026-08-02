{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  quickshell = inputs.quickshell.packages.${system}.quickshell;
  inherit (config.user) username;
  home-manager = config.home-manager.users.${username};
  inherit (home-manager.home) homeDirectory;
in {
  imports = [
    inputs.dms-plugin-registry.nixosModules.default
  ];

  config = lib.mkIf config.services.xserver.enable {
    programs = {
      niri.enable = true;

      dms-shell = {
        enable = true;
        quickshell.package = quickshell;
        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };

        # Core features
        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)

        plugins = {
          calculator.enable = true;
          catWidget.enable = true;
          dankLauncherKeys.enable = true;
          niriWindows.enable = true;
          powerOptions.enable = true;
          wallpaperCarousel.enable = true;
          nixPackageRunner.enable = true;
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

    services = {
      displayManager = {
        dms-greeter = {
          enable = true;
          quickshell.package = quickshell;
          compositor.name = config.programs.niri.package.pname;
          # Sync your user's DankMaterialShell theme with the greeter
          configHome = homeDirectory;
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
  };
}
