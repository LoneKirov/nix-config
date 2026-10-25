{config, ...}: {
  imports = [
    ./rbw.nix
    ./ssh.nix
    ./wezterm.nix
  ];

  wsl = {
    defaultUser = config.user.username;
    useWindowsDriver = true;
  };

  environment.sessionVariables = {
    # mesa dlopens libd3d12.so and libdxcore.so by bare name, and nix's glibc
    # doesn't read /etc/ld.so.cache, so without this it falls back to llvmpipe.
    # /usr/lib/wsl/lib holds only the windows host's libraries, unlike
    # /run/opengl-driver/lib, which also has mesa's
    # https://github.com/nix-community/NixOS-WSL/issues/454
    LD_LIBRARY_PATH = ["/usr/lib/wsl/lib"];

    # mesa's d3d12 driver prefers an integrated gpu over the nvidia card, and
    # falls back to llvmpipe when d3d12 fails on it
    MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
  };

  # nvidia-smi from the windows driver is a generic linux binary that loads
  # libnvidia-ml.so.1 at runtime
  # https://github.com/nix-community/NixOS-WSL/issues/947
  programs.nix-ld = {
    enable = true;
    libraries = [config.wsl.wslLib];
  };

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
