_: {
  perSystem = {
    inputs',
    pkgs,
    self',
    ...
  }: {
    # tools the hosts install, built with this flake's nixpkgs, so
    # `nix build .#jj-gh` matches what the hosts deploy. CI pushes every one of
    # them to the public lonekirov.cachix.org, so nothing unfree belongs here
    packages = {
      inherit (inputs'.jj-starship.packages) jj-starship;
      jj-gh = inputs'.jj-gh.packages.default;
      comma-fish-completion = pkgs.callPackage ../../packages/comma-fish-completion {
        inherit (inputs'.nix-index-database.packages) comma-with-db nix-index-with-small-db;
      };
      # cache.nixos.org has the full wezterm but not this build
      wezterm-headless = pkgs.wezterm.headless;
    };

    # the completion leans on comma's generated completion, nix-locate's output
    # and fish's own helpers, any of which a flake.lock bump can change
    checks.comma-fish-completion =
      pkgs.runCommandLocal "comma-fish-completion-check" {
        nativeBuildInputs = [inputs'.nix-index-database.packages.comma-with-db pkgs.fish];
      } ''
        if ! HOME=$TMPDIR fish --no-config ${../../packages/comma-fish-completion/check.fish} \
          ${self'.packages.comma-fish-completion}/share/fish/vendor_completions.d 2>stderr \
          || [ -s stderr ]; then
          cat stderr >&2
          exit 1
        fi
        touch $out
      '';
  };
}
