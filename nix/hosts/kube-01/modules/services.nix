{ ... }:
{
  imports = [
    ./services/borgmatic.nix
    ./services/borgbackup.nix
    ./services/notifications.nix
    ./services/prometheus-exporters.nix
    ./services/traefik.nix
    # ./services/cadvisor.nix
    ./services/immich.nix
    ./services/prusa-connect.nix
    ./services/bookorbit.nix
    ./services/docmost.nix
    ./services/patreon-dl.nix
    ./services/paperless.nix
    ./services/qbittorrent.nix
    ./services/audiomuse-ai.nix
    ./services/jellyfin.nix
    ./services/calibre.nix
    # ./services/couchdb.nix
    ./services/samba.nix

    # To impl.
    # ./services/change-detection.nix
  ];
}
