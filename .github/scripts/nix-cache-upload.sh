#!/bin/sh

set -eu
set -f

# the nix daemon runs this without the job's environment, so CI installs it
# into runner.temp next to attic's client and the login it reads
dir=${0%/*}
export XDG_CONFIG_HOME="$dir"
IFS='
 '

# atticd's database sometimes keeps a push waiting and then fails it, and
# attic's client neither retries nor times out
push() {
  n=1
  until timeout 1800 "$dir/attic-client/bin/attic" push kanto "$@"; do
    [ "$n" -lt 3 ] || return 1
    sleep $((n * 30))
    n=$((n + 1))
  done
}

if [ -n "${OUT_PATHS-}" ]; then
  # nix fails the build when the post-build hook fails, so paths that still
  # won't push are left for CI to push once the builds are done
  push $OUT_PATHS >>"$dir/attic-push.log" 2>&1 ||
    printf '%s\n' $OUT_PATHS >>"$dir/attic-push-failed"
elif [ -s "$dir/attic-push-failed" ]; then
  grep -E '❌|Error' "$dir/attic-push.log" || true
  push $(cat "$dir/attic-push-failed")
fi
