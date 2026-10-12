# usage: fish --no-config check.fish <directory holding ,.fish>
#
# fish only loads completions for commands on PATH, so `,` has to be on it and
# dig mustn't be, as dig stands in for a command comma hasn't installed.
#
# Errors in completion code go straight to fish's stderr rather than through
# `complete -C`, so the caller has to fail on any stderr output too.
set -p fish_complete_path $argv[1]

function expect --argument-names line pattern
    set -l results (complete -C $line)
    if not string match -qr -- $pattern $results
        echo "completing '$line' gave nothing matching $pattern, only:" >&2
        printf '  %s\n' $results[1..10] >&2
        return 1
    end
end

set -l failed 0
# command names from nix-locate's output
expect ', di' '^dig\t'; or set failed 1
# arguments from the completion fish ships for the command
expect ', dig +sh' '^\+short\t'; or set failed 1
# comma's own flags, from the completion comma ships
expect ', --ins' '^--install\t'; or set failed 1
exit $failed
