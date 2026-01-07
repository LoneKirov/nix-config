{...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    nvim = inputs'.nixvim.legacyPackages.makeNixvimWithModule {
      inherit pkgs;
      module = {
        imports = [
          ../../nixvim
          ../../nixvim/lsp/nix.nix
        ];
      };
    };
  in {
    devShells.default = with pkgs;
      mkShell {
        buildInputs = [nvim];
        packages = [
          alejandra
          nil
          nixd
        ];
      };
    formatter = pkgs.alejandra;
  };
}
