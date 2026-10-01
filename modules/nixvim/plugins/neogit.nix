{
  config,
  lib,
  ...
}: let
  inherit (config.plugins.neogit) enable;
in {
  config = {
    plugins = {
      neogit.enable = lib.mkDefault true;
      diffview.enable = lib.mkDefault enable;
    };

    keymaps = lib.mkIf enable [
      {
        action = "<cmd>Neogit<CR>";
        key = "<leader>gg";
        mode = "n";
        options.desc = "Neogit";
      }
    ];
  };
}
