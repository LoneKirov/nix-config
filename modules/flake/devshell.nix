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
          nurl
          sops
          ssh-to-age
        ];
      };
  };
}
