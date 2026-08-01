{ ... }:
{
  imports = [
    ./services/borgmatic.nix
    ./services/k3s.nix
    ./services/notifications.nix
    ./services/prometheus-exporters.nix

    # To migrate, once all else is prepared.
    # ./services/immich.nix
    # ./services/paperless.nix

    # To impl.
    # ./services/jellyfin.nix
    # ./services/qbittorrent.nix
    # ./services/change-detection.nix
    # ./services/audiomuse.nix
    # ./services/traefik.nix
  ];
}
