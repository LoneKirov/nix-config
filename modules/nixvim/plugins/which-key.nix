{
  config,
  lib,
  ...
}: {
  config = {
    plugins.which-key.enable = lib.mkDefault true;

    keymaps = lib.mkIf config.plugins.which-key.enable [
      {
        action = "<cmd>WhichKey<CR>";
        key = "<leader>?";
        mode = "n";
        options.desc = "Show keymaps";
      }
    ];
  };
}
