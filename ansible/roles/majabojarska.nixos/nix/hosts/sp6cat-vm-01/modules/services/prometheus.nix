{ config, ... }:
{
  # https://wiki.nixos.org/wiki/Prometheus
  # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
  services.prometheus = {
    enable = true;
    port = config.sp6catVm01.ports.prometheus;
    listenAddress = "127.0.0.1";

    # This hack is needed to write Prometheus data outside of /var/lib
    # One would think think scenario would be supported, but alas.
    # https://discourse.nixos.org/t/custom-prometheus-data-directory/50741/6
    stateDir = "prometheus";

    globalConfig.scrape_interval = "10s";

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.smartctl.port}" ];
          }
        ];
      }
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.zfs.port}" ];
          }
        ];
      }
      {
        job_name = "chrony";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.chrony.port}" ];
          }
        ];
      }
    ];
  };

  # This is also part of the hack
  # systemd.tmpfiles.rules = [
  #   "D ${config.sp6catVm01.storage.wdUsbHddMountPath}/prometheus/data 0751 prometheus prometheus - -"
  #   "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - ${config.sp6catVm01.storage.wdUsbHddMountPath}/prometheus/data"
  # ];
}
