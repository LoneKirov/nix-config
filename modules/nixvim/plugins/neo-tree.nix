{
  config,
  lib,
  ...
}: let
  inherit (config.plugins) neo-tree transparent;
in {
  config = {
    plugins.neo-tree = {
      enable = lib.mkDefault true;
      settings = {
        close_if_last_window = true;
        # the log file can't be opened in nixvim's sandboxed startup check
        log_to_file = false;
        filesystem = {
          use_libuv_file_watcher = true;
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
        };
      };
    };

    extraConfigLua = lib.mkIf (neo-tree.enable && transparent.enable) ''
      require('transparent').clear_prefix('NeoTree')
    '';

    keymaps = lib.mkIf neo-tree.enable [
      {
        action = "<cmd>Neotree toggle<CR>";
        key = "<leader>e";
        mode = "n";
        options.desc = "Toggle file explorer";
      }
    ];
  };
}
