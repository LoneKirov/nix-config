{...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = with pkgs;
      mkShell {
        buildInputs = [];
        packages = [
          alejandra
          nil
          nixd
        ];
      };
  };
}
