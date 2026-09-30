{pkgs, ...}: {
  programs.fuse.enable = true;
  environment.systemPackages = with pkgs; [
    sshfs
  ];
  user.hm = {
    config,
    lib,
    ...
  }: {
    home.activation.syncSSHConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if winhome=$(${config.windows.profile}) && winprofile=$(${config.windows.profile} -w); then
        run cp -L -f ${config.home.homeDirectory}/.ssh/config "$winhome/.ssh/"

        ${lib.optionalString config.services.rbw-agent.enable ''
        cat << EOF | run tee -a "$winhome/.ssh/config" > /dev/null

        Host *
          IdentityAgent $winprofile\${lib.replaceStrings ["/"] ["\\"] config.services.rbw-agent.windowsSocket}
        EOF
      ''}
      else
        warnEcho "Couldn't find the Windows profile; skipping SSH config sync"
      fi
    '';
  };
}
