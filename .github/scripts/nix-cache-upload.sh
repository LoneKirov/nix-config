#!/bin/sh

set -eu
set -f

export PATH=$PATH:/nix/var/nix/profiles/default/bin
# the nix daemon runs this without the job's environment, so CI installs it
# into runner.temp next to the ssh-agent socket
export SSH_AUTH_SOCK="${0%/*}/ssh-agent.sock"
export NIX_SSHOPTS="-o StrictHostKeyChecking=accept-new"
export IFS=' '
exec nix copy --to ssh-ng://cache-upload@cache.kanto.casa --substitute-on-destination $OUT_PATHS
