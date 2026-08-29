{
  inputs,
  pkgs,
  ...
}: {
  packages = let
    system = pkgs.stdenv.hostPlatform.system;
    kirov-neovim = inputs.kirov.lib.evalNixvim {inherit system;};
  in
    with pkgs; [
      age
      alejandra
      kirov-neovim.config.build.package
      nom
      nurl
      sops
      ssh-to-age
    ];

  languages.nix.enable = true;

  tasks = {
    "test:all-systems".exec = "nix flake check --build-all --all-systems";
  };

  enterTest = ''
    nix flake check --build-all
  '';
}
