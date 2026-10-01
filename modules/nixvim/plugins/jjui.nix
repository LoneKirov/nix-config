{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.plugins.jjui.enable = lib.mkEnableOption "jjui.nvim" // {default = true;};

  config = lib.mkIf config.plugins.jjui.enable {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "jjui";
        src = inputs.jjui-nvim;
        postPatch = ''
          substituteInPlace lua/jjui.lua \
            --replace-fail 'exec_jjui({ "jjui" })' 'exec_jjui({ "${lib.getExe pkgs.jjui}" })' \
        '';
      })
    ];

    extraConfigLua = ''
      require('jjui')
    '';

    keymaps = [
      {
        action = "<cmd>Jjui<CR>";
        key = "<leader>jj";
        mode = "n";
        options.desc = "jjui";
      }
    ];
  };
}
