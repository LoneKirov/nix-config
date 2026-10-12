{
  comma-with-db,
  lib,
  linkFarm,
  nix-index-with-small-db,
  replaceVars,
  runCommandLocal,
  util-linuxMinimal,
}: let
  # every command comma can find, with one package that provides it, sorted
  # for look's binary search
  commands = runCommandLocal "comma-commands" {nativeBuildInputs = [nix-index-with-small-db];} ''
    nix-locate --at-root --type x --type s --regex '/bin/[^/]*' \
      | awk '$1 !~ /^\(/ { cmd = $NF; sub(/.*\//, "", cmd); pkg = $1; sub(/\.out$/, "", pkg); print cmd "\t" pkg }' \
      | LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2 \
      | awk -F '\t' '$1 != prev { print; prev = $1 }' >$out
  '';
  # https://github.com/nix-community/comma/issues/123
  # comma's own fish completion only covers its flags. Once
  # https://github.com/nix-community/comma/pull/125 lands, it completes command
  # names itself, so `commands` and the look call can go, leaving the argument
  # completion.
  completion = replaceVars ./completion.fish {
    comma = comma-with-db;
    look = lib.getExe' util-linuxMinimal "look";
    inherit commands;
  };
in
  linkFarm "comma-fish-completion" {
    "share/fish/vendor_completions.d/,.fish" = completion;
  }
