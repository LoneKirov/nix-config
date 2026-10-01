{lib, ...}: {
  imports = [
    ./nix.nix
  ];

  config = {
    plugins = {
      lspconfig.enable = lib.mkDefault true;
      lsp-format.enable = lib.mkDefault true;
    };
    lsp.inlayHints.enable = true;
  };
}
