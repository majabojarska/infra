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
      port = config.sp6catVm01.ports.prometheusExporterNode;
      listenAddress = "127.0.0.1";

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
      listenAddress = "127.0.0.1";
      devices = [
        "/dev/disk/by-id/ata-WDC_WD10SMZW-11Y0TS0_WD-WX61AB7P31RY"
      ];
    };

    zfs = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterZfs;
      listenAddress = "127.0.0.1";
    };

    chrony = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterChrony;
      listenAddress = "127.0.0.1";
    };

    fail2ban = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterFail2ban;
      listenAddress = "127.0.0.1";
    };

    wireguard = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterWireguard;
      listenAddress = "127.0.0.1";
    };

    ping = {
      enable = true;
      port = config.sp6catVm01.ports.prometheusExporterPing;
      listenAddress = "127.0.0.1";
      # https://mynixos.com/nixpkgs/option/services.prometheus.exporters.ping.settings
      # https://github.com/czerwonk/ping_exporter
      settings = {
        targets = [
          "1.1.1.1" # Cloudflare
          "192.168.1.1" # Home
          "10.10.0.3" # Baczek
          "192.168.75.1" # HSWRO router (from LAN)
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

  # Workaround for incorrect Service section generation, which adds an empty newline before --web.listen-address.
  #
  # For example:
  # lip 12 03:46:16 sp6cat-vm-01 systemd[1]: /etc/systemd/system/prometheus-fail2ban-exporter.service:16: Unknown key '--web.listen-address' in section [Service], ignoring.
  #
  #  systemctl cat prometheus-fail2ban-exporter.service
  # /etc/systemd/system/prometheus-fail2ban-exporter.service -> /nix/store/27y7l6n38i8j2klwjn38fmlqa2qxvyk8-unit-prometheus-fail2ban-exporter.service/prometheus-fail2ban-exp>
  # [Unit]
  # After=network.target
  # Requires=prometheus-fail2ban-exporter-setup.service

  # [Service]
  # Environment="LOCALE_ARCHIVE=/nix/store/qdw41kp2vg3882nkrf0sxsz4702yx9pf-glibc-locales-2.42-67/lib/locale/locale-archive"
  # Environment="PATH=/nix/store/sr26flm2nkfa12dkrwj2630kqsfakky4-coreutils-9.11/bin:/nix/store/zjwih3d9rrrw4ixll52wsy0538p7vdfd-findutils-4.10.0/bin:/nix/store/w8xlvapzxcz23b>
  # Environment="TZDIR=/nix/store/ga3b95jkyvknam1nxl25r95nyk87ix25-tzdata-2026b/share/zoneinfo"
  # CapabilityBoundingSet=
  # DeviceAllow=
  # DynamicUser=false
  # ExecStart=/nix/store/jcwnq6abaj19zxda36p4yy96xh3nry72-prometheus-fail2ban-exporter-0.10.3/bin/fail2ban-prometheus-exporter \
  #   --collector.f2b.exit-on-socket-connection-error \

  #   --web.listen-address="127.0.0.1:9104" \
  #   --collector.f2b.socket=/run/fail2ban/fail2ban.sock
  #
  # ---
  #
  # There shouldn't be a newline before --web.listen-address.
  systemd.services.prometheus-fail2ban-exporter.serviceConfig.ExecStart = lib.mkForce (
    lib.concatStringsSep " " [
      (lib.getExe pkgs.prometheus-fail2ban-exporter)
      "--collector.f2b.exit-on-socket-connection-error"
      "--web.listen-address=127.0.0.1:${toString config.services.prometheus.exporters.fail2ban.port}"
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

    exporterFail2banLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.fail2ban.listenAddress}:${toString config.services.prometheus.exporters.fail2ban.port}";
    };

    exporterPingLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.ping.listenAddress}:${toString config.services.prometheus.exporters.ping.port}/metrics";
    };

    exporterChronyLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.chrony.listenAddress}:${toString config.services.prometheus.exporters.chrony.port}/metrics";
    };

    exporterWireguardLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.exporters.wireguard.listenAddress}:${toString config.services.prometheus.exporters.wireguard.port}/metrics";
    };

  };
}
