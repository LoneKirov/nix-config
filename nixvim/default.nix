{...}: {
  viAlias = true;
  vimAlias = true;
  plugins = {
    lspconfig.enable = true;
    lsp-format.enable = true;
    blink-cmp = {
      enable = true;
      settings.keymap.preset = "super-tab";
    };
    telescope.enable = true;
    neo-tree.enable = true;
    web-devicons.enable = true;
  };
  lsp = {
    inlayHints.enable = true;
  };
  keymaps = [
    {
      action = "<cmd>Neotree filesystem<CR>";
      key = "<leader>ntf";
      mode = "n";
    }
    {
      action = "<cmd>Neotree git_status<CR>";
      key = "<leader>ntg";
      mode = "n";
    }
  ];
}
