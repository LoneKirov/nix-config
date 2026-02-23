{
  lib,
  pkgs,
  ...
}: {
  local.kirov.home-manager = {
    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          moltres = {
            host = "moltres";
            forwardAgent = true;
          };
          zapdos = {
            host = "zapdos";
            forwardAgent = true;
          };
        };
      };
      bw.sshAgent = true;
    };
    systemd.user.services.afuse-sshfs = {
      Unit = {
        Description = "afuse sshfs automount";
      };
      Service = {
        Type = "simple";
        RuntimeDirectory = "sshfs";
        RuntimeDirectoryPreserve = true;
        ExecStart = ''
          ${lib.getExe' pkgs.afuse "afuse"} -f \
            -o timeout=60 \
            -o auto_unmount \
            -o flushwrites \
            -o mount_template="${lib.getExe' pkgs.sshfs "sshfs"} -o reconnect %%r: %%m" \
            -o unmount_template="umount -l %%m" \
            %t/sshfs
        '';
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
