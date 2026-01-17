{pkgs, ...}: {
  home-manager.users.kirov = {
    programs.ssh = {
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
    systemd.user.services.afuse-sshfs = {
      Unit = {
        Description = "afuse sshfs automount";
      };
      Service = {
        Type = "simple";
        RuntimeDirectory = "sshfs";
        RuntimeDirectoryPreserve = true;
        ExecStart = ''
          ${pkgs.afuse}/bin/afuse -f \
            -o timeout=60 \
            -o auto_unmount \
            -o flushwrites \
            -o mount_template="${pkgs.sshfs}/bin/sshfs -o reconnect %%r: %%m" \
            -o unmount_template="umount -l %%m" \
            %t/sshfs
        '';
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
