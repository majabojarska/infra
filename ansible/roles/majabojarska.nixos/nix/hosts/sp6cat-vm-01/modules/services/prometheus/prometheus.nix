{
  pkgs,
  config,
  lib,
  ...
}:
let
  healthchecks = import ../../../../../modules/healthchecks.nix { inherit lib pkgs; };
in
{
  imports = [
    ./exporters.nix
  ];

  # https://wiki.nixos.org/wiki/Prometheus
  # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
  services.prometheus = {
    enable = true;
    port = config.hosts.sp6catVm01.ports.prometheus;
    listenAddress = "127.0.0.1";
    retentionTime = "15d";

    checkConfig = "syntax-only";
    # This hack is needed to write Prometheus data outside of /var/lib
    # One would think think scenario would be supported, but alas.
    # https://discourse.nixos.org/t/custom-prometheus-data-directory/50741/6
    stateDir = "prometheus";

    globalConfig.scrape_interval = "10s";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.hosts.sp6catVm01.ports.prometheusMetrics}"
            ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              "kube-01.${config.globals.homeDomain}:${toString config.hosts.kube01.ports.prometheusExporterNode}"
              "pve-01.home.majabojarska.dev:9100"
              "192.168.81.50:9100" # PVE sp6cat-01 - TODO: figure out why domain resolution doesn't work for this host
            ];
          }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
              "kube-01.${config.globals.homeDomain}:${toString config.hosts.kube01.ports.prometheusExporterSmartctl}"
            ];
          }
        ];
      }
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}"
              "kube-01.${config.globals.homeDomain}:${toString config.hosts.kube01.ports.prometheusExporterZfs}"
            ];
          }
        ];
      }
      {
        job_name = "chrony";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.chrony.port}" ];
          }
        ];
      }
      {
        job_name = "fail2ban";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.fail2ban.port}"
              "kube-01.${config.globals.homeDomain}:${toString config.hosts.kube01.ports.prometheusExporterFail2ban}"
            ];
          }
        ];
      }
      {
        job_name = "wireguard";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.wireguard.port}" ];
          }
        ];
      }
      {
        job_name = "ping";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.ping.port}"
              "kube-01.${config.globals.homeDomain}:${toString config.hosts.kube01.ports.prometheusExporterPing}"
            ];
          }
        ];
        metric_relabel_configs = [
          {
            # https://github.com/czerwonk/ping_exporter#ping_loss_ratio-vs-ping_loss_percent
            source_labels = [ "__name__" ];
            regex = "ping_loss_ratio";
            target_label = "__name__";
            replacement = "ping_loss_percent";
          }
        ];
      }
      {
        job_name = "traefik";
        static_configs = [
          {
            targets = [
              config.services.traefik.staticConfigOptions.entryPoints.metrics.address
            ];
          }
        ];
      }

    ];
  };

  # This is also part of the hack
  # systemd.tmpfiles.rules = [
  #   "D ${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/prometheus/data 0751 prometheus prometheus - -"
  #   "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - ${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/prometheus/data"
  # ];
  system.preSwitchChecks = {
    prometheusLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
    };
  };

}
