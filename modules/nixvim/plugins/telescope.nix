{lib, ...}: let
  picker = action: desc: {
    inherit action;
    options.desc = desc;
  };
in {
  config.plugins.telescope = {
    enable = lib.mkDefault true;
    extensions.fzf-native.enable = true;
    keymaps = {
      "<leader>ff" = picker "find_files" "Find files";
      "<leader>fb" = picker "buffers" "Find buffers";
      "<leader>fg" = picker "git_files" "Find git files";
      "<leader>fr" = picker "oldfiles" "Recent files";
      "<leader>sg" = picker "live_grep" "Grep";
      "<leader>sw" = picker "grep_string" "Grep word under cursor";
      "<leader>sb" = picker "current_buffer_fuzzy_find" "Search buffer";
      "<leader>sh" = picker "help_tags" "Search help";
      "<leader>sk" = picker "keymaps" "Search keymaps";
      "<leader>gc" = picker "git_commits" "Git commits";
      "<leader>gs" = picker "git_status" "Git status";
    };
  };
}
