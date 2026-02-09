{...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = with pkgs;
      mkShell {
        buildInputs = [];
        packages = [
          age
          alejandra
          nil
          nixd
          sops
          ssh-to-age
        ];
      };
  };
}
