{
  config,
  lib,
  ...
}: {
  config = {
    plugins.which-key = {
      enable = lib.mkDefault true;
      # name the leader groups in the popup
      settings.spec = [
        {
          __unkeyed-1 = "<leader>f";
          group = "find";
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "search";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "git";
        }
        {
          __unkeyed-1 = "<leader>j";
          group = "jj";
        }
      ];
    };

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
