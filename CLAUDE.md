# CLAUDE.md

NixOS and home-manager flake for the hosts listed in the [README](README.md), which also covers deploying.

## Version control

- This is a colocated jj repo, so git's HEAD is always detached. Use `jj` (`jj commit -m`, `jj describe`), not `git commit`, `git checkout` or git branches.
- Changes reach `main` through squash-merged PRs. Push or open PRs only when asked.

## Commit messages

- Subject: lowercase, imperative, says what the change does, about 70 characters at most, no trailing period. For example: `limit nixremote to CI cache uploads on moltres`.
- Put the reason in the body, as bullets when the change has several parts.

## Checking changes

- `nix fmt` formats with alejandra.
- `devenv test` runs `nix flake check --build-all`, the same as CI.
- To confirm a refactor changes no host, compare every host's system derivation against the parent revision:

  ```sh
  base="git+file://$PWD?rev=$(jj log -r @- --no-graph -T commit_id)"
  drv() { nix eval --raw "$1#nixosConfigurations.$2.config.system.build.toplevel.drvPath"; }
  for h in $(nix eval --raw path:.#nixosConfigurations --apply 'c: toString (builtins.attrNames c)'); do
    [ "$(drv "$base" "$h")" = "$(drv path:. "$h")" ] && echo "$h: same" || echo "$h: CHANGED"
  done
  ```

## Conventions

- `hosts/default.nix` is the host inventory. NixOS modules read this host's flags from `config.host` and every host from `config.hosts`; each host directory is a plain NixOS module.
- home-manager modules run inside NixOS (`user.hm`) and standalone through `lib.homeManagerConfiguration`, where there's no `osConfig`. Gate them on `config.host.*`, and read anything else from `osConfig` with an `or` fallback.
- Set values hosts may want to change with `lib.mkDefault`, so they don't need `mkForce`. Put a custom option's default in the option itself.
- Every non-WSL host boots with a tmpfs root. A module that keeps state outside `/nix` and `/home` must add it to `persist.directories` or `persist.files` itself.
