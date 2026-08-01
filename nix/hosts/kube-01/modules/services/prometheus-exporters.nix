{
  pkgs,
  lib,
  config,
  ...
}:
let
  healthchecks = import ../../../../modules/healthchecks.nix { inherit lib pkgs; };
in
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = config.hosts.kube01.ports.prometheusExporterNode;
      listenAddress = "0.0.0.0";

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
      port = config.hosts.kube01.ports.prometheusExporterSmartctl;
      listenAddress = "0.0.0.0";
      devices = [
        "/dev/disk/by-id/ata-WDC_WD10SMZW-11Y0TS0_WD-WX61AB7P31RY"
      ];
    };

    zfs = {
      enable = true;
      port = config.hosts.kube01.ports.prometheusExporterZfs;
      listenAddress = "0.0.0.0";
    };

    fail2ban = {
      enable = true;
      port = config.hosts.kube01.ports.prometheusExporterFail2ban;
      listenAddress = "0.0.0.0";
      # listenAddress and port overridden through an ExecStart override below.
    };

    ping = {
      enable = true;
      port = config.hosts.kube01.ports.prometheusExporterPing;
      listenAddress = "0.0.0.0";
      # https://mynixos.com/nixpkgs/option/services.prometheus.exporters.ping.settings
      # https://github.com/czerwonk/ping_exporter
      settings = {
        targets = [
          "1.1.1.1" # Cloudflare

          # Home
          "opnsense.home.majabojarska.dev"
          "netgear-switch.home.majabojarska.dev"
          "unifi.home.majabojarska.dev"

          # HSWRO
          "192.168.75.1" # HSWRO router (from LAN)
          "sp6cat-01.hswro.majabojarska.dev"
          "sp6cat-vm-01.hswro.majabojarska.dev"
        ];

        dns = {
          refresh = "2m";
          nameserver = "1.1.1.1";
        };

        ping = {
          interval = "15s";
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

  systemd.services.prometheus-fail2ban-exporter.serviceConfig.ExecStart = lib.mkForce (
    lib.concatStringsSep " " [
      (lib.getExe pkgs.prometheus-fail2ban-exporter)
      "--collector.f2b.exit-on-socket-connection-error"
      "--web.listen-address=0.0.0.0:${toString config.services.prometheus.exporters.fail2ban.port}"
      "--collector.f2b.socket=/run/fail2ban/fail2ban.sock"
    ]
  );

  system.preSwitchChecks = {
    exporterNodeLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}/metrics";
    };

    exporterSmartctlLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.smartctl.listenAddress}:${toString config.services.prometheus.exporters.smartctl.port}/metrics";
    };

    exporterZfsLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.zfs.listenAddress}:${toString config.services.prometheus.exporters.zfs.port}/metrics";
    };

    exporterPingLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.ping.listenAddress}:${toString config.services.prometheus.exporters.ping.port}/metrics";
    };
  };
}
