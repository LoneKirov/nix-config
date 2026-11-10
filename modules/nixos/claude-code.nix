{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
  inherit (config.user) flakeCheckout username;
  inherit (config) wsl;

  commas = lib.concatStringsSep ", ";
  spoken = names:
    if lib.length names > 1
    then "${commas (lib.init names)} and ${lib.last names}"
    else commas names;
  # vulpix is a nix-darwin host outside this flake's inventory
  sshHosts = lib.attrNames (lib.filterAttrs (name: host: host.ssh && name != hostName) config.hosts) ++ ["vulpix"];
  # hosts whose sudo accepts the forwarded agent (see pam.nix)
  agentSudoHosts = lib.attrNames (lib.filterAttrs (_: host: host.ssh && ! host.gui) config.hosts);
  wslInterop = wsl.enable && wsl.wslConf.interop.enabled;
  windowsProfiles = "${wsl.wslConf.automount.root}/c/Users";

  atuin = config.home-manager.users.${username}.programs.atuin;
  # The hooks `atuin hook install claude-code` writes to ~/.claude/settings.json,
  # kept here because the installer pins atuin's store path at install time.
  atuinHook = [
    {
      matcher = "^Bash$";
      hooks = [
        {
          type = "command";
          command = "${lib.getExe atuin.package} hook claude-code";
        }
      ];
    }
  ];

  settings = {
    autoMode = {
      environment = [
        "### Org-wide"
        "**Organization**: None configured"
        "**Cloud provider(s)**: None configured"
        "**Repository visibility**: PUBLIC — LoneKirov/nix-config (github.com) is public per gh API"
        "**Internal sharing / snippet hosting**: None configured — treat public paste/gist services as outside the trust boundary"
        "**Secrets management**: GitHub Actions CI secrets referenced by name only (AUTOMERGE_APP_PRIVATE_KEY, CACHE_SIGNING_KEY, GITHUB_TOKEN, SSH_PRIVATE_KEY, TS_AUDIENCE, TS_OAUTH_CLIENT_ID) — no values seen"
        "**Default / protected branches**: Default branch `main`; ruleset `Default` active (treat as protecting `main` even though classic protected-branches list shows only `main`)"
        "**CI/CD deploy targets**: GitHub Actions (nix-ci.yml) builds push to host `moltres`, which serves a binary cache at `cache.kanto.casa` consumed by `slowpoke`, `articuno`, and `mew`; daily auto-upgrade targets `moltres` and `slowpoke`"
        "**Network posture**: None configured"
        ("**Host containment**: Claude Code runs unsandboxed as the user (${username}) on ${hostName}, a personal machine with open internet. Its commands can use the rbw ssh-agent socket, which logs into ${spoken sshHosts} without a prompt, and ${spoken agentSudoHosts} accept that forwarded agent for sudo with no password, so ssh access to them is effectively root unless a rule stops it"
          + lib.optionalString wslInterop ". ${hostName} is a WSL distro with interop on, so any command can get root in it without a password through `wsl.exe -u root`")
        "**Source control**: The trusted repo and its remotes only — origin (github.com:LoneKirov/nix-config.git, public), articuno (ssh://articuno/.config/nix-config), vulpix (ssh://vulpix/etc/nix-darwin)"
        "**Trusted internal domains**: cache.kanto.casa (self-hosted binary cache, referenced in README and contacted in session)"
        "**Trusted cloud buckets**: None configured"
        "**Key internal services**: moltres (home server: media, SSO, binary cache, backups); articuno, mew, slowpoke (deploy/backup targets via btrbk and nh os switch)"
        "**Internal package registry**: None configured. cache.kanto.casa (see Trusted internal domains) is a supplementary Nix binary cache, not a replacement for upstream: cache.nixos.org and other public substituters are expected, and adding them is not a registry bypass"
        ("**Sensitive data locations & audiences**: Every secret or credential is sensitive whether or not it is listed here, and its value has no permitted audience: not the transcript (the user included), files, commits, command lines, or any network destination. Known locations on the user's machines and hosts: the Bitwarden vault through rbw or bw, and the rbw-agent socket under $XDG_RUNTIME_DIR/rbw; decrypted sops-nix secrets (/run/secrets, /run/secrets.d, /run/secrets-for-users) and any sops decryption output; the age keys under ~/.config/sops; ssh private keys (/etc/ssh/ssh_host_*_key, btrbk keys, ~/.ssh/id_*); the attic token (~/.config/attic) and the binary cache signing key on moltres; the GitHub CLI token (~/.config/gh/hosts.yml, `gh auth token`); Claude Code's own ~/.claude/.credentials.json; the atuin sync key (~/.local/share/atuin/key); GNOME keyrings (~/.local/share/keyrings); browser profiles with cookies and saved logins (~/.config/chromium, ~/.config/BraveSoftware); "
          + lib.optionalString wsl.enable "the Windows profiles under ${windowsProfiles}, whose .ssh holds the rbw-agent bridge socket and whose AppData holds browser profiles and credential stores; "
          + "Tailscale auth keys and state; and the values of the CI secrets AUTOMERGE_APP_PRIVATE_KEY, CACHE_SIGNING_KEY, GITHUB_TOKEN, SSH_PRIVATE_KEY, TS_AUDIENCE and TS_OAUTH_CLIENT_ID, whose names may be referenced but never their values. Not sensitive: the encrypted *.sops.yaml files in the repo, the .sops.yaml recipients, and public keys (*.pub, keys/)")
        "**Data retention / declassification**: None configured"
        "**Sensitive remote targets**: moltres is production: it runs SSO, media, the binary cache, and the backups for the other hosts. Read-only inspection of moltres is routine (see the Read-only Host Diagnostics allow rule); anything that changes its state needs the user to ask for it. Also any namespace, host, or container whose name carries `prod` or `production` as a whole word or name segment"
        "**Protected deployment namespaces / environments**: moltres; otherwise fall back to the Sensitive remote targets heuristic"
        "**Protected IaC scopes**: IAM, RBAC, networking, quota, and node-pool resources; anything whose name or tag carries `prod` or `production` as a whole word or name segment"
        "### User-specific"
        "**Primary use of Claude Code**: personal NixOS/home-manager flake configuration and deployment (hobby infrastructure-as-code)"
        "**Trusted repo**: ${flakeCheckout} (public GitHub repo LoneKirov/nix-config) and its remotes — origin (github.com, public), articuno (ssh://articuno/.config/nix-config), vulpix (ssh://vulpix/etc/nix-darwin); since this repo is public, only its own work belongs in it — content ported from elsewhere is not"
        "**Org-specific CLIs**: None configured — project-local tools observed: jj (Jujutsu, used instead of git for commits — see CLAUDE.md), nh (nix helper used for `nh os switch` deploys), devenv (test runner), alejandra (nix formatter)"
        "**Routine under this repo's prefix**: `jj commit`/`jj describe` for version control (git HEAD stays detached by design per CLAUDE.md); `nix fmt .`, `devenv test`, `nix flake check --build-all` for checking changes; pushes/PRs to origin only when explicitly asked per CLAUDE.md"
      ];

      allow = [
        "$defaults"
        "Read-only Host Diagnostics: Over ssh to ${commas sshHosts}, running commands as the login user that only inspect state (journalctl; systemctl status, show, cat, list-units, list-timers or is-active, system or --user; podman ps or logs for the user's own containers; df, findmnt, ip, ss, uptime; reading non-secret files under /etc, /nix/store or /proc), including small read-only scripts piped to `bash -s`. This is routine on every host, production moltres included. It doesn't cover sudo or any other privilege escalation, anything that writes, restarts, reloads or otherwise changes state, or reading anything listed under Sensitive data locations"
      ];

      soft_deny =
        [
          "$defaults"
          "Remote Host Deploy [must name: the deploy and the target host]: Activating a configuration on another machine (${commas sshHosts}) with any tool: nh os or nh darwin switch, boot or test with --target-host; nixos-rebuild or darwin-rebuild with --target-host, --use-remote-sudo or --sudo; nix copy followed by switch-to-configuration; deploy-rs or colmena; or starting a host's auto-upgrade. Clears when the user's own message asks for that deploy to that host, and that request also covers the remote sudo the deploy itself needs"
          "Unrequested Push [must name: pushing, and the remote or bookmark]: Any push or pull request change from this repo, by any tool and to any remote including articuno and vulpix: jj git push, git push, gh pr create, merge, edit, close or review, or gh api writes. This overrides the default Git Push Destination exception, because the user's instructions say pushes and PRs happen only when asked, and whatever reaches main is built by CI and picked up by the daily auto-upgrade on moltres and slowpoke. Clears only when the user's own message in this session asks to push or to open or change a PR"
          "Remote Privilege Escalation [must name: the privileged command and the host]: Gaining root on another machine (${commas sshHosts}, or any host reached over ssh) with sudo, sudo-rs, doas, run0, su, pkexec, machinectl shell or similar, even for read-only commands like `sudo journalctl` or `sudo podman inspect`, and by any route: directly over ssh, inside a script or heredoc piped to ssh, through systemd-run or other D-Bus calls, through nix, by talking to the rbw ssh-agent socket directly, or by feeding a password to `sudo -S`. sudo on ${spoken agentSudoHosts} authenticates silently against the forwarded agent once rbw is unlocked, so this rule is the only check. Clears only when the user's own message asks for that privileged action on that host, either directly or by agreeing to a specific proposal from Claude that named the command and the host; a general request such as 'debug moltres' doesn't count. Deploys the user asked for fall under Remote Host Deploy instead"
          "Credential Changes [must name: the credential and the change]: Creating, rotating, revoking, unlocking or re-scoping any credential or auth state: rbw or bw login, unlock, lock, sync, config, or vault writes (add, edit, remove, generate); ssh-keygen or age-keygen writing keys; ssh-add changes to an agent; gh auth login, logout, refresh or setup-git; attic login or token commands; tailscale up, login or logout; sops updatekeys or rotate; generating binary cache keys; changing authorized_keys or git credential helpers on any machine. Clears only when the user's own message asks for that specific change"
        ]
        ++ lib.optional wslInterop "WSL Root [must name: the root command]: Getting root in this WSL distro through Windows interop, such as `wsl.exe -u root` or `wsl.exe --user root`, or any other Windows-side route around the distro's own sudo, which asks for a password. Clears only when the user's own message asks for that root command, either directly or by agreeing to a specific proposal from Claude that named it";

      hard_deny = [
        "$defaults"
        "Secret Exposure: Reading, printing, decrypting, copying, or transmitting the value of any secret or credential listed under Sensitive data locations, or of any other secret, by any route: rbw or bw get, code or export; sops -d, --decrypt, decrypt, edit, exec-env, exec-file, or bare `sops <file>`; cat, grep, cp, base64 or a script run over a private key, token or secret file; nix eval or builtins.readFile on a secret path; ssh-to-age -private-key; gh auth token or gh auth status --show-token; environment or process dumps that would include tokens. Operations that use a secret without revealing it, like ssh through the agent, fall under the other rules. This holds even when the user asks"
      ];
    };

    permissions = {
      ask =
        [
          "Bash(jj git push *)"
          "Bash(git push *)"
          "Bash(gh pr create *)"
          "Bash(gh pr merge *)"
          "Bash(nh os *--target-host*)"
          "Bash(nh darwin *--target-host*)"
          "Bash(nixos-rebuild *--target-host*)"
          "Bash(ssh *sudo*)"
          "Bash(sops *)"
        ]
        ++ lib.optionals wslInterop [
          "Bash(wsl.exe *-u root*)"
          "Bash(wsl.exe *--user root*)"
        ];

      deny =
        [
          "Bash(rbw *)"
          "Bash(rbw-agent*)"
          "Bash(bw *)"
          "Bash(sops -d *)"
          "Bash(sops --decrypt *)"
          "Bash(sops decrypt *)"
          "Bash(sops edit *)"
          "Bash(sops exec-env *)"
          "Bash(sops exec-file *)"
          "Bash(gh auth *)"
          "Bash(*-private-key*)"
          "Bash(*/run/secrets*)"
          "Bash(*ssh_host_*_key)"
          "Bash(*ssh_host_*_key *)"
          "Bash(*.config/sops*)"
          "Bash(*.config/attic*)"
          "Bash(*.config/gh/hosts.yml*)"
          "Bash(*.local/share/rbw*)"
          "Bash(*.cache/rbw*)"
          "Bash(*.credentials.json*)"
          "Bash(*.local/share/atuin/key*)"
          "Bash(*.local/share/keyrings*)"
          "Read(~/.ssh/id_*)"
          "Read(~/.config/sops/**)"
          "Read(~/.config/attic/**)"
          "Read(~/.config/gh/hosts.yml)"
          "Read(~/.local/share/rbw/**)"
          "Read(~/.cache/rbw/**)"
          "Read(~/.claude/.credentials.json)"
          "Read(~/.local/share/atuin/key)"
          "Read(~/.local/share/keyrings/**)"
          "Read(~/.config/chromium/**)"
          "Read(~/.config/BraveSoftware/**)"
          "Read(//run/secrets/**)"
          "Read(//run/secrets.d/**)"
          "Read(//run/secrets-for-users/**)"
          "Read(//etc/ssh/ssh_host_*_key)"
        ]
        ++ lib.optionals wsl.enable [
          "Bash(*${windowsProfiles}/*/.ssh*)"
          "Bash(*${windowsProfiles}/*/AppData*)"
          "Read(/${windowsProfiles}/*/.ssh/**)"
          "Read(/${windowsProfiles}/*/AppData/**)"
        ];
    };

    hooks = lib.optionalAttrs atuin.enable {
      PreToolUse = atuinHook;
      PostToolUse = atuinHook;
      PostToolUseFailure = atuinHook;
    };
  };
in {
  # Managed settings rather than ~/.claude/settings.json: the file is
  # root-owned, so a process running as the user can't loosen these rules, and
  # they sit above the user's own settings, which keep the preferences Claude
  # Code writes itself (theme, model, effort). On WSL, interop lets any process
  # get root through `wsl.exe -u root`, so there this is shared config rather
  # than a lock.
  config = lib.mkIf (flakeCheckout != null) {
    environment.etc."claude-code/managed-settings.json" = {
      source = (pkgs.formats.json {}).generate "claude-code-managed-settings.json" settings;
      # a copy rather than the usual /etc/static link: Claude Code warns about a
      # managed file that links outside /etc/claude-code
      mode = "0444";
    };
  };
}
