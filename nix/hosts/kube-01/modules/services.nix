{ config, ... }:

{
  imports = [
    ./services/borgmatic.nix
    ./services/k3s.nix
    ./services/notifications.nix
    ./services/prometheus-exporters.nix
  ];
}
