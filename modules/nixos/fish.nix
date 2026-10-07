{lib, ...}: {
  programs = {
    fish = {
      enable = lib.mkDefault true;
      # also covers root's fish (e.g. sudo -s), which doesn't read home-manager's config
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };
  };
}
