{self, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    _neovim = self.lib.evalNixvim {inherit system;};
  in {
    devShells.default = with pkgs;
      mkShell {
        buildInputs = [];
        packages = [
          age
          alejandra
          _neovim.config.build.package
          nil
          nixd
          nurl
          sops
          ssh-to-age
        ];
      };
  };
}
