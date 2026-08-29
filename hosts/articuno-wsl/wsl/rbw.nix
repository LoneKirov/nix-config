_: {
  config = {
    home-manager.users.kirov = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.services.rbw-agent.windowsSocket = let
        inherit (lib) types;
      in {
        winPath = lib.mkOption {
          type = types.nonEmptyStr;
          default = ''C:\Users\kirov\.ssh\rbw-agent.sock'';
          readOnly = true;
        };
        wslPath = lib.mkOption {
          type = types.nonEmptyStr;
          default = "/mnt/c/Users/kirov/.ssh/rbw-agent.sock";
          readOnly = true;
        };
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
              ${lib.getExe' pkgs.coreutils "rm"} -f ${windowsSocket.wslPath}
            '';
          in {
            Type = "simple";
            Environment = [''SSH_AUTH_SOCK="%t/rbw/ssh-agent-socket"''];
            ExecStartPre = "${cleanupScript}";
            ExecStart = "${pkgs.writeShellScript "start-rbw-agent-bridge" ''
              export WSL_INTEROP=$(${lib.getExe' pkgs.iproute2 "ss"} -xl | grep -o '/run/WSL/[0-9]*_interop' | head -n 1)

              WIN_WINSOCAT_PATH=$(/mnt/c/Windows/System32/where.exe winsocat.exe 2>/dev/null | head -n 1 | tr -d '\r')
              WSL_WINSOCAT_PATH=$(/sbin/wslpath -u "$WIN_WINSOCAT_PATH")

              exec $WSL_WINSOCAT_PATH "UNIX-LISTEN:${windowsSocket.winPath}" WSL:"${lib.getExe pkgs.socat} STDIO unix-connect:$SSH_AUTH_SOCK"
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
