{
  config,
  inputs,
  lib,
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
    ];

  # the kirov age key is the Bitwarden secure note "kirov age key", so sops
  # reads it through rbw and it never sits unencrypted on disk
  env.SOPS_AGE_KEY_CMD = pkgs.writeShellScript "sops-age-key" ''
    # rbw hands pinentry the tty on its stdin, but sops runs key commands with
    # stdin on /dev/null, so pass on the terminal sops is running in
    tty=$(${lib.getExe' pkgs.procps "ps"} -o tty= -p $$)
    case $tty in pts/* | tty*) export RBW_TTY=/dev/$tty ;; esac
    exec rbw get 'kirov age key'
  '';

  languages.nix.enable = true;

  claude.code.enable = true;

  # devenv test starts every process, and CI and local test runs shouldn't
  # push to the cache
  processes = lib.mkIf (!config.devenv.isTesting) {
    attic-watch-store.exec = "${lib.getExe pkgs.attic-client} watch-store kanto";
  };

  tasks = {
    "test:all-systems".exec = "nix flake check --build-all --all-systems";
  };

  enterTest = ''
    nix flake check --build-all
  '';
}
