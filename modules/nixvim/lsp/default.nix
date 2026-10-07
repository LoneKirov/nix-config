{lib, ...}: {
  imports = [
    ./nix.nix
  ];

  config = {
    plugins = {
      lspconfig.enable = lib.mkDefault true;
      lsp-format.enable = lib.mkDefault true;
    };
    lsp = {
      inlayHints.enable = true;
      # neovim maps the other common actions (grn, gra, grr, gri, K, ...) itself
      keymaps = [
        {
          key = "gd";
          lspBufAction = "definition";
          options.desc = "Go to definition";
        }
      ];
    };
  };
}
