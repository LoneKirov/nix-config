{config, ...}: {
  imports = [
    ./rbw.nix
    ./ssh.nix
    ./wezterm.nix
  ];

  wsl.defaultUser = config.user.username;

  nixpkgs.hostPlatform = "x86_64-linux";

  user.hm = {
    lib,
    pkgs,
    ...
  }: {
    options.windows.profile = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = ''
        Script printing the Windows user's profile directory as a WSL path,
        or as a Windows path when passed `-w`. Exits non-zero if Windows can't be reached.
      '';
      default = pkgs.writeShellScript "windows-profile" ''
        export WSL_INTEROP=$(${lib.getExe' pkgs.iproute2 "ss"} -xl | grep -o '/run/WSL/[0-9]*_interop' | head -n 1)
        # cmd.exe warns when started from a UNC working directory
        cd /mnt/c || exit 1
        profile=$(/mnt/c/Windows/System32/cmd.exe /d /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
        case "$profile" in
          "" | *%*) exit 1 ;;
        esac
        if [ "''${1-}" = -w ]; then
          printf '%s\n' "$profile"
        else
          /sbin/wslpath -u "$profile"
        fi
      '';
    };
  };
}
