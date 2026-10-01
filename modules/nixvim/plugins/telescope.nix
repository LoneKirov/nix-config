{lib, ...}: {
  config.plugins.telescope = {
    enable = lib.mkDefault true;
    extensions.fzf-native.enable = true;
    keymaps = {
      "<leader>tff" = "find_files";
      "<leader>tg" = "grep_string";
      "<leader>tlg" = "live_grep";
      "<leader>tb" = "buffers";
      "<leader>tbff" = "current_buffer_fuzzy_find";
      "<leader>tgf" = "git_files";
      "<leader>tgc" = "git_commits";
      "<leader>tgs" = "git_status";
    };
  };
}
