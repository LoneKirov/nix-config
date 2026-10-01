{inputs, ...}: {
  imports = [
    ./lsp
    ./plugins
    ./theme.nix
  ];

  config = {
    nixpkgs = {
      config.allowUnfree = true;
      source = inputs.nixpkgs;
    };

    viAlias = true;
    vimAlias = true;
  };
}
