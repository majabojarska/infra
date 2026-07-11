{ config, ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = config.kube01.ports.prometheusExporterNode;

      # For the list of available collectors, run, depending on your install:
      # - Flake-based: nix run nixpkgs#prometheus-node-exporter -- --help
      # - Classic: nix-shell -p prometheus-node-exporter --run "node_exporter --help"
      enabledCollectors = [
        "ethtool"
        "softirqs"
        "systemd"
        "tcpstat"
      ];
    };

    smartctl = {
      enable = true;
      port = config.kube01.ports.prometheusExporterSmartctl;
      devices = [
        "/dev/disk/by-id/wwn-0x5000000000002a82"
        "/dev/disk/by-id/wwn-0x50000000000029f3"
        "/dev/disk/by-id/wwn-0x5000000123456e8a"
      ];
    };

  };
}
