{pkgs, ...}: {
  programs.fuse.enable = true;
  environment.systemPackages = with pkgs; [
    sshfs
  ];
  home-manager.users.kirov = {
    config,
    lib,
    ...
  }: {
    home.activation.syncSSHConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD cp -L -f ${config.home.homeDirectory}/.ssh/config /mnt/c/Users/kirov/.ssh/

      ${lib.optionalString config.services.rbw-agent.enable ''
        cat << 'EOF' | $DRY_RUN_CMD tee -a /mnt/c/Users/kirov/.ssh/config > /dev/null

        Host *
          IdentityAgent ${config.services.rbw-agent.windowsSocket.winPath}
        EOF
      ''}
    '';
  };
}
