{
  config,
  lib,
  ...
}: {
  config = {
    programs.neovim = lib.mkMerge [
      {enable = lib.mkDefault true;}
      (lib.mkIf config.programs.neovim.enable {
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
      })
    ];
  };
}
