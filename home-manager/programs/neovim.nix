{
  config,
  lib,
  ...
}: {
  config = {
    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
