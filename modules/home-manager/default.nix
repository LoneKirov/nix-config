{
  imports = [
    ./fonts.nix
    ./host.nix
    ./programs
    ./theme.nix
  ];

  config = {
    xdg.enable = true;
  };
}
