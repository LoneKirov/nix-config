#!/bin/sh

set -eu
set -f

export PATH=$PATH:/nix/var/nix/profiles/default/bin
export SSH_AUTH_SOCK=/tmp/nix_ssh_agent.sock
export NIX_SSHOPTS="-o StrictHostKeyChecking=accept-new"
export IFS=' '
exec nix copy --to ssh-ng://nixremote@cache.kanto.casa --substitute-on-destination --no-check-sigs $OUT_PATHS
