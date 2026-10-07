_: {
  perSystem = {inputs', ...}: {
    # the jj tools every host installs, built with this flake's nixpkgs, so
    # `nix build .#jj-gh` matches what the hosts deploy
    packages = {
      inherit (inputs'.jj-starship.packages) jj-starship;
      jj-gh = inputs'.jj-gh.packages.default;
    };
  };
}
