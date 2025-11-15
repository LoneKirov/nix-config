{
  config,
  lib,
  ...
}: {
  config = {
    programs.direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = true;
    };
  };
}
