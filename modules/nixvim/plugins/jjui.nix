{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.plugins.jjui) enable;
in {
  options.plugins.jjui.enable = lib.mkEnableOption "jjui.nvim";

  config = {
    plugins.jjui.enable = lib.mkDefault true;

    extraPlugins = lib.mkIf enable [
      (pkgs.vimUtils.buildVimPlugin {
        name = "jjui";
        src = inputs.jjui-nvim;
        postPatch = ''
          substituteInPlace lua/jjui.lua \
            --replace-fail 'exec_jjui({ "jjui" })' 'exec_jjui({ "${lib.getExe pkgs.jjui}" })' \
        '';
      })
    ];

    extraConfigLua = lib.mkIf enable ''
      require('jjui')
    '';

    keymaps = lib.mkIf enable [
      {
        action = "<cmd>Jjui<CR>";
        key = "<leader>jj";
        mode = "n";
        options.desc = "jjui";
      }
    ];
  };
}
