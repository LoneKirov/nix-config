{
  imports = [
    ./fonts.nix
    ./programs
  ];

  config = {
    xdg.enable = true;
  };
}
