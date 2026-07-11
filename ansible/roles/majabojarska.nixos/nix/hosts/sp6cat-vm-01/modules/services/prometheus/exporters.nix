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

    fail2ban = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterFail2ban;
    };

    wireguard = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterWireguard;
    };

    ping = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterPing;
      # https://mynixos.com/nixpkgs/option/services.prometheus.exporters.ping.settings
      # https://github.com/czerwonk/ping_exporter
      settings = {
        targets = [
          "1.1.1.1"
        ];

        dns = {
          refresh = "2m";
          nameserver = "1.1.1.1";
        };

        ping = {
          interval = "60s";
          timeout = "3s";
          history-size = 42;
          payload-size = 120;
          fw-mark = 222;
        };

        options = {
          disableIPv6 = false;
        };
      };
    };

  };
}
