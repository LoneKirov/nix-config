{
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = {
    # fallback for when dms hasn't generated a colorscheme
    colorschemes.tokyonight.enable = lib.mkDefault true;

    # dms writes its colorscheme to ~/.config/nvim/colors/dms.lua
    impureRtp = true;

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "base46";
        src = inputs.base46;
        nvimRequireCheck = "base46";
      })
    ];

    extraConfigLuaPost = ''
      require('base46')
      pcall(vim.cmd.colorscheme, 'dms')
    '';
  };
}
