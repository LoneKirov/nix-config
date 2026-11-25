_: {
  config = {
    user.hm = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.services.rbw-agent.windowsSocket = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = ".ssh/rbw-agent.sock";
        readOnly = true;
        description = "Windows-side agent socket, relative to the Windows profile directory.";
      };

      config = {
        systemd.user.services.rbw-agent-bridge = lib.mkIf config.services.rbw-agent.enable {
          Unit = let
            agent = config.sshAuthSock.systemd.socketProviderUnit;
          in {
            Description = "rbw-agent socket bridge";
            # Each connection opens the agent socket afresh, so the bridge
            # doesn't need restarting along with the agent
            Wants = [agent];
            # set-SSH_AUTH_SOCK puts SSH_AUTH_SOCK in the manager environment
            After = [agent "set-SSH_AUTH_SOCK.service"];
          };

          Service = let
            inherit (config.services.rbw-agent) windowsSocket;
            inherit (config.windows) withInterop;
            cleanupScript = pkgs.writeShellApplication {
              name = "stop-rbw-agent-bridge";
              runtimeInputs = [pkgs.coreutils];
              text = ''
                /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
                  "Get-CimInstance Win32_Process -Filter 'Name = \"winsocat.exe\"' | Where-Object { \$_.CommandLine -match 'rbw-agent.sock' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }" \
                  2>/dev/null || true
                if winhome=$(${config.windows.profile}); then
                  rm -f "$winhome/${windowsSocket}"
                fi
              '';
            };
            startScript = pkgs.writeShellApplication {
              name = "start-rbw-agent-bridge";
              text = ''
                if ! found=$(/mnt/c/Windows/System32/where.exe winsocat.exe 2>/dev/null); then
                  echo "winsocat.exe isn't on the Windows PATH" >&2
                  exit 1
                fi
                # where.exe prints every match on its own CRLF-terminated line
                winsocat=$(/sbin/wslpath -u "''${found%%$'\r'*}")
                if ! profile=$(${config.windows.profile} -w); then
                  echo "couldn't find the Windows profile" >&2
                  exit 1
                fi

                # Without -e, wsl.exe runs the command through the user's shell,
                # adding its startup to every agent request and putting anything
                # it prints into the agent stream. Without -d, it goes to the
                # default distro.
                exec "$winsocat" \
                  "UNIX-LISTEN:$profile\${lib.replaceStrings ["/"] ["\\"] windowsSocket}" \
                  "EXEC:C:\Windows\System32\wsl.exe -d NixOS -e ${lib.getExe pkgs.socat} STDIO UNIX-CONNECT:$SSH_AUTH_SOCK"
              '';
            };
          in {
            Type = "simple";
            ExecStartPre = "${withInterop} ${lib.getExe cleanupScript}";
            ExecStart = "${withInterop} ${lib.getExe startScript}";
            ExecStop = "${withInterop} ${lib.getExe cleanupScript}";
            Restart = "on-failure";
          };

          Install.WantedBy = ["default.target"];
        };
      };
    };
  };
}
