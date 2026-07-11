{ config, ... }:
{
  services.prometheus.exporters = {

    node = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterNode;

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
      port = config.sp6catVm01.ports.prometheusExporterSmartctl;
      devices = [
        "/dev/disk/by-id/ata-WDC_WD10SMZW-11Y0TS0_WD-WX61AB7P31RY"
      ];
    };

    zfs = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterZfs;
    };

    chrony = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterChrony;
    };

  };
}
