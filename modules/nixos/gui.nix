{
  config,
  pkgs,
  inputs,
  username,
  ...
}: let
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
in {
  imports = [
    inputs.dms-plugin-registry.modules.default
  ];

  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    programs = {
      # Niri Compositor
      niri.enable = true;

      # DankMaterialShell
      dms-shell = {
        enable = true;
        quickshell.package = quickshell;
        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };

        # Core features
        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)

        plugins = {
          niriWindows.enable = true;
          tailscale.enable = true;
        };
      };

      # DankSearch
      dsearch = {
        enable = true;

        # Systemd service configuration
        systemd = {
          enable = true; # Enable systemd user service
          target = "graphical-session.target"; # Only start in graphical sessions
        };
      };
    };

    services = {
      # DankGreeter
      displayManager.dms-greeter = {
        enable = true;
        quickshell.package = quickshell;
        compositor.name = config.programs.niri.package.pname;
        # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
        configHome = config.home-manager.users.${username}.home.homeDirectory;

        # Save the logs to a file
        logs = {
          save = true;
          path = "/tmp/dms-greeter.log";
        };
      };

      # dms uses upower for battery stats
      upower.enable = true;
    };
  };
}
