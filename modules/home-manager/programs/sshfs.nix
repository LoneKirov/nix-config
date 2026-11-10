{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  options.programs.sshfs.enable =
    lib.mkEnableOption "sshfs"
    // {
      # unprivileged mounts need a setuid fusermount3, which NixOS only installs
      # with programs.fuse; standalone, nixpkgs' libfuse falls back to the
      # distro's fusermount3 on PATH
      default = osConfig.programs.fuse.enable or true;
    };

  config = lib.mkIf config.programs.sshfs.enable {
    home.packages = with pkgs; [sshfs];
  };
}
