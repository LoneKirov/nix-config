{lib, ...}: {
  programs = {
    fish = {
      enable = lib.mkDefault true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };
  };
}
