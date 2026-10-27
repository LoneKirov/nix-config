#!/bin/sh

set -eu
set -f

# the nix daemon runs this without the job's environment, so CI installs it
# into runner.temp next to attic's client and the login it reads
export XDG_CONFIG_HOME="${0%/*}"
export IFS=' '
exec "${0%/*}/attic-client/bin/attic" push kanto $OUT_PATHS
