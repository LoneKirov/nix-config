{
  inputs,
  pkgs,
  ...
}: {
  packages = let
    system = pkgs.stdenv.hostPlatform.system;
    # evaluated from the working tree rather than the kirov input's store
    # copy, so devenv watches modules/nixvim and reloads the shell on edits
    nvim =
      (inputs.kirov.lib.evalNixvim {
        inherit system;
        baseModule = ./modules/nixvim;
      }).config.build.package;
  in
    with pkgs; [
      age
      alejandra
      claude-code
      nvim
      nix-output-monitor
      nurl
      sops
      ssh-to-age
    ];

  languages.nix.enable = true;

  claude.code.enable = true;

  tasks = {
    "test:all-systems".exec = "nix flake check --build-all --all-systems";
  };

  enterTest = ''
    nix flake check --build-all
  '';
}
