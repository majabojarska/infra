{
  pkgs,
  config,
  lib,
  ...
}:
let
  healthchecks = import ../../../../../modules/healthchecks.nix { inherit lib pkgs; };
  mkPveScrapeJob = import ./mk-pve-scrape-job.nix { inherit config; };
in
{
  imports = [
    ./exporters.nix
    ./cadvisor.nix
  ];

  # https://wiki.nixos.org/wiki/Prometheus
  # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
  services.prometheus = {
    enable = true;
    port = config.hosts.sp6catVm01.ports.prometheus;
    listenAddress = "127.0.0.1";
    retentionTime = "7d";

    # extraFlags = [
    #   "--log.level=debug"
    # ];

    checkConfig = "syntax-only";
    # This hack is needed to write Prometheus data outside of /var/lib
    # One would think think scenario would be supported, but alas.
    # https://discourse.nixos.org/t/custom-prometheus-data-directory/50741/6
    stateDir = "prometheus";

    globalConfig.scrape_interval = "15s";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.hosts.sp6catVm01.ports.prometheus}"
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
              "opnsense.home.majabojarska.dev:9100"
              "sp6cat-01.hswro.majabojarska.dev:9100"
            ];
          }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.hosts.sp6catVm01.ports.cadvisor}"
              "kube-01.${config.globals.homeDomain}:${toString config.hosts.kube01.ports.cadvisor}"
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
      (mkPveScrapeJob {
        jobName = "pve-01.home.majabojarska.dev";
        cfgName = "pve-01-home";
        target = [ "pve-01.home.majabojarska.dev" ];
      })
      (mkPveScrapeJob {
        jobName = "sp6cat-01.hswro.majabojarska.dev";
        cfgName = "sp6cat-01-hswro";
        target = [ "sp6cat-01.hswro.majabojarska.dev" ];
      })
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
