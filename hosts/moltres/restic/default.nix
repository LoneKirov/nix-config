{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.host.backup) receive;
  # btrbk sends every host's /home and /persistent here (modules/nixos/btrfs.nix).
  # arr-data stays home: it's mostly media the arr apps can fetch again, and
  # too big to send offsite
  sources =
    lib.concatMap (host: ["${host}/home" "${host}/persistent"])
    (lib.attrNames (lib.filterAttrs (_: host: lib.elem "moltres" host.backup.targets) config.hosts))
    ++ map (subvolume: "moltres/${subvolume}") ["home" "persistent" "arr" "syncthing"];
  staging = "${receive}/.restic-proton";
  state = "/var/lib/restic-backups-proton";

  # Proton keeps deleted files in the trash, where they count against storage.
  # Emptying at most weekly keeps recently pruned packs there to restore
  emptyTrash = pkgs.writeShellApplication {
    name = "restic-proton-empty-trash";
    runtimeInputs = [pkgs.findutils pkgs.rclone];
    text = ''
      stamp=${state}/trash-emptied
      if [[ -n $(find "$stamp" -mtime -7 2>/dev/null) ]]; then
        exit 0
      fi
      rclone cleanup proton:
      touch "$stamp"
    '';
  };

  unstage = pkgs.writeShellApplication {
    name = "restic-proton-unstage";
    runtimeInputs = [pkgs.btrfs-progs];
    text = ''
      shopt -s nullglob
      for subvolume in ${staging}/*/*; do
        btrfs subvolume delete "$subvolume"
      done
    '';
  };

  stage = pkgs.writeShellApplication {
    name = "restic-proton-stage";
    runtimeInputs = [pkgs.btrfs-progs];
    text = ''
      newest() {
        local i snapshots=("$1"/*)
        # btrbk's timestamps sort chronologically, and a receive still in
        # progress is writable
        for ((i = ''${#snapshots[@]} - 1; i >= 0; i--)); do
          if [[ $(btrfs property get -ts "''${snapshots[i]}" ro) == ro=true ]]; then
            echo "''${snapshots[i]}"
            return
          fi
        done
        echo "no complete snapshot in $1" >&2
        return 1
      }

      # left behind if moltres went down mid-run
      ${lib.getExe unstage}
      for src in ${lib.escapeShellArgs sources}; do
        snapshot=$(newest ${receive}/"$src")
        mkdir -p "$(dirname ${staging}/"$src")"
        # a read-only snapshot would keep the copy's received_uuid, which btrfs
        # receive matches to find the parent for btrbk's next incremental send
        btrfs subvolume snapshot "$snapshot" ${staging}/"$src"
        btrfs property set -ts ${staging}/"$src" ro true
      done
    '';
  };
in {
  sops.secrets.restic-proton = {
    format = "dotenv";
    sopsFile = ./restic.sops.env;
    key = "";
  };

  services.restic.backups.proton = {
    repository = "rclone:proton:restic";
    environmentFile = config.sops.secrets.restic-proton.path;
    rcloneConfig = {
      type = "protondrive";
      # restic retries a failed upload under the same name, which Proton
      # refuses while the failed attempt's draft is still there
      replace_existing_draft = true;
    };
    # rclone saves its Proton session here, so restic's later commands and
    # runs reuse it instead of logging in again
    rcloneConfigFile = "${state}/rclone.conf";
    initialize = true;
    # restic only reports progress to a terminal unless this is set; once a
    # minute shows how a multi-day upload is going without flooding the journal
    progressFps = 1.0 / 60;
    paths = map (src: "${staging}/${src}") sources;
    backupPrepareCommand = lib.getExe stage;
    backupCleanupCommand = lib.getExe unstage;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      # paths change when a host joins or leaves, and this lets the old
      # snapshots age out with the rest
      "--group-by host"
    ];
    checkOpts = [
      "--with-cache"
      # downloads a sample of packs, to catch uploads Proton's API changes broke
      "--read-data-subset=1%"
    ];
  };

  systemd.services.restic-backups-proton = {
    # fewer, larger files mean fewer Proton API calls and shorter listings
    environment.RESTIC_PACK_SIZE = "64";
    serviceConfig = {
      StateDirectory = "restic-backups-proton";
      StateDirectoryMode = "0700";
      Nice = 19;
      IOSchedulingClass = "idle";
      # only runs once backup, prune and check have all passed, so packs a prune
      # deleted stay restorable until a check confirms nothing needs them
      ExecStartPost = lib.getExe emptyTrash;
    };
  };

  persist.directories = [
    "/var/cache/restic-backups-proton"
    state
  ];
}
