# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # hardware scan configuration
    ./disk-config.nix # disk configuration used to build /etc/fstab
  ];

  nix = {
    settings = {
      # Enable flakes
      experimental-features = ["nix-command" "flakes"];
      # Have nix use xdg
      use-xdg-base-directories = true;
    };
  };

  boot = {
    loader = {
      # Disable systemd-boot EFI boot loader. Lanzaboote handles it.
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    # Setup Lanzaboote for SecureBoot
    lanzaboote = {
      enable = true;
      # Using sbctl for key generation and management
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };

    # Enable systemd within initrd
    initrd.systemd.enable = true;

    # Use latest kernel.
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # Hibernate is broken on kernels >6.17.9
    kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_17.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "sha256-bQiAO5U8UJ30jUTTKB7TklJDIdi7NT6yHAVVeQyPjgY=";
        };
        version = "6.17.9";
        modDirVersion = "6.17.9";
      };
    });

    kernelParams = [
      "zswap.enabled=1" # enable zswap
      "zswap.max_pool_percent=25" # limit zswap to 20% of RAM
      "zswap.shrinker_enabled=1" # shrink the pool proactively on memory pressure
    ];
  };

  # Setup preservation to maintain state between wipes of /
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      directories = [
        "/etc/nixos" # persist until user/github repo is setup
        "/etc/secureboot" # persist secureboot config
        "/etc/NetworkManager/system-connections" # NM connections
        "/var/lib/nixos" # stores nixos state for generating stable uids and gids
        "/var/lib/fwupd" # firmware update store
        "/var/lib/sbctl" # persist secureboot keys managed by sbctl
        "/var/lib/systemd/coredump" # coredump store
        "/var/lib/systemd/rfkill" # RF kill switch state store
        "/var/lib/systemd/timers" # timers state store
        "/var/log" # system logs
      ];
      files = [
        {
          # machine id. needs to be available early in boot
          file = "/etc/machine-id";
          how = "symlink";
          inInitrd = true;
        }
        {
          # random seed. needs to be available early in boot
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
        }
      ];
    };
  };

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };
  users.users.kirov = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
  };
  home-manager = {
    users.kirov = {pkgs, ...}: {
      imports = [
        ../home-manager/shells/zsh.nix
        ../home-manager/programs
      ];

      xdg.enable = true;
      home = {
        packages = with pkgs; [
          nerd-fonts.fira-code
        ];
        stateVersion = "25.11";
      };
    };
  };
  programs.zsh.enable = true;
  programs.niri.enable = true; # niri

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    brightnessctl
    git
    sbctl
    tpm2-tools
    tpm2-tss
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
