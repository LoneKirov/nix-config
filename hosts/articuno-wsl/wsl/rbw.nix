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
          Unit = {
            Description = "rbw-agent socket bridge";
            After = ["network.target"];
            Requires = ["rbw-agent.service"];
          };

          Service = let
            inherit (config.services.rbw-agent) windowsSocket;
            cleanupScript = pkgs.writeShellScript "stop-rbw-agent-bridge" ''
              export WSL_INTEROP=$(${lib.getExe' pkgs.iproute2 "ss"} -xl | grep -o '/run/WSL/[0-9]*_interop' | head -n 1)
              /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
                "Get-CimInstance Win32_Process -Filter 'Name = \"winsocat.exe\"' | Where-Object { \$_.CommandLine -match 'rbw-agent.sock' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }" \
                2>/dev/null || true
              if winhome=$(${config.windows.profile}); then
                ${lib.getExe' pkgs.coreutils "rm"} -f "$winhome/${windowsSocket}"
              fi
            '';
          in {
            Type = "simple";
            Environment = [''SSH_AUTH_SOCK="%t/rbw/ssh-agent-socket"''];
            ExecStartPre = "${cleanupScript}";
            ExecStart = "${pkgs.writeShellScript "start-rbw-agent-bridge" ''
              export WSL_INTEROP=$(${lib.getExe' pkgs.iproute2 "ss"} -xl | grep -o '/run/WSL/[0-9]*_interop' | head -n 1)

              WIN_WINSOCAT_PATH=$(/mnt/c/Windows/System32/where.exe winsocat.exe 2>/dev/null | head -n 1 | tr -d '\r')
              WSL_WINSOCAT_PATH=$(/sbin/wslpath -u "$WIN_WINSOCAT_PATH")
              WIN_PROFILE=$(${config.windows.profile} -w) || exit 1

              exec $WSL_WINSOCAT_PATH "UNIX-LISTEN:$WIN_PROFILE\${lib.replaceStrings ["/"] ["\\"] windowsSocket}" WSL:"${lib.getExe pkgs.socat} STDIO unix-connect:$SSH_AUTH_SOCK"
            ''}";
            ExecStop = "${cleanupScript}";
            Restart = "on-failure";
          };

          Install.WantedBy = ["default.target"];
        };
      };
    };
  };
}
