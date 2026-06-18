{...}: {
  imports = [
    ./fonts.nix
    ./programs
    ./theme.nix
  ];

  config = {
    xdg.enable = true;
  };
}
