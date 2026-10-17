{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    checks.lint = let
      src = lib.fileset.toSource {
        root = ../..;
        fileset = lib.fileset.fileFilter (file: file.hasExt "nix") ../..;
      };
    in
      pkgs.runCommandLocal "lint" {
        nativeBuildInputs = [config.formatter pkgs.deadnix pkgs.statix];
      } ''
        cd ${src}
        ${lib.getExe config.formatter} --check .
        deadnix --fail .
        statix check .
        touch $out
      '';
  };
}
