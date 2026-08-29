_: {
  # https://github.com/nix-community/lanzaboote/issues/584
  # https://github.com/systemd/systemd/issues/40381
  systemd.services.systemd-pcrlock-secureboot-authority.enable = false;
}
