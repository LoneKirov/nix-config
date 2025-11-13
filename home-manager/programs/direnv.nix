{
  config,
  lib,
  ...
}: {
  config = {
    programs.direnv = {
      enable = lib.mkDefault true;
      enableZshIntegration = config.programs.zsh.enable;
      nix-direnv.enable = true;
    };
  };
}
