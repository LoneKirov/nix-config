# CLAUDE.md

NixOS and home-manager flake for the hosts listed in the [README](README.md), which also covers deploying.

## Version control

- This is a colocated jj repo, so git's HEAD is always detached. Use `jj` (`jj commit -m`, `jj describe`), not `git commit`, `git checkout` or git branches.
- Changes reach `main` through squash-merged PRs. Push or open PRs only when asked.

## Commit messages

- Subject: lowercase, imperative, says what the change does, about 70 characters at most, no trailing period. For example: `limit nixremote to CI cache uploads on moltres`.
- Put the reason in the body, as bullets when the change has several parts.

## Code comments

- Write for someone reading the file cold, without this conversation, the PR or the history. A comment explains why the code is this way when the code can't show it: an upstream bug, an interaction with another module, a constraint that isn't visible here.
- Don't describe the change itself ("now uses", "instead of", "moved from", "as discussed", "fixed"). That goes in the commit message. If a comment would stop making sense once the change is merged, leave it out.
- Don't restate what the code does. Most lines need no comment.
- Link the upstream issue for a workaround, so it's clear when the workaround can go.

## Checking changes

- `nix fmt .` formats with alejandra. Plain `nix fmt` passes no paths, so alejandra reads stdin and fails.
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
