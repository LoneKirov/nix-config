{
  imports = [
    ./boot.nix
    ./btrfs.nix
    ./flatpak.nix
    ./gui.nix
    ./impermanence.nix
    ./networking.nix
    ./nix.nix
    ./pam.nix
    ./podman.nix
    ./secure-boot.nix
    ./sops.nix
    ./ssh.nix
    ./sudo.nix
    ./system-packages.nix
    ./time.nix
    ./tpm2.nix
    ./user.nix
    ./zswap.nix
  ];

  config.nixpkgs.overlays = [
    (final: prev: {
      wezterm = prev.wezterm.overrideAttrs (finalAttrs: previousAttrs: {
        postPatch = ''
          echo ${finalAttrs.version} > .tag
        '';
      });
    })
  ];
}
