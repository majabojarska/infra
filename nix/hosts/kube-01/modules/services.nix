{ ... }:
{
  imports = [
    ./services/borgmatic.nix
    ./services/k3s.nix
    ./services/notifications.nix
    ./services/prometheus-exporters.nix
    ./services/traefik.nix
    ./services/cadvisor.nix

    # To migrate, once all else is prepared.
    ./services/immich.nix
    ./services/paperless.nix
    ./services/qbittorrent.nix
    # ./services/audiomuse-ai.nix
    # ./services/jellyfin.nix

    # To impl.
    # ./services/change-detection.nix
  ];
}
