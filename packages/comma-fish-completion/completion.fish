# this file replaces the one comma ships, so it loads that one first
source @comma@/share/fish/vendor_completions.d/,.fish

complete -c , -n '__fish_,_needs_command' -x -a "(@look@ -- (commandline -ct) @commands@)"

function __comma_complete_args
    set -l cmd (__fish_,_needs_command)
    # fish only loads completions for commands on PATH, which the one comma
    # runs usually isn't
    if not type -q -- $cmd
        status get-file completions/$cmd.fish 2>/dev/null | source
    end
    __fish_complete_subcommand -- -P --picker -F --nixpkgs-flake -c --print-completions --cache-level
end
complete -c , -n 'not __fish_,_needs_command' -x -a '(__comma_complete_args)'
