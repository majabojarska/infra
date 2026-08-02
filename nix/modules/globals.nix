{ lib, ... }:

{
  options.globals = {
    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "majabojarska98@gmail.com";
      description = "Administrator email address";
    };

    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "majabojarska.dev";
      description = "Base domain name";
    };

    cloudDomain = lib.mkOption {
      type = lib.types.str;
      default = "cloud.majabojarska.dev";
      description = "Cloud subdomain";
    };

    homeDomain = lib.mkOption {
      type = lib.types.str;
      default = "home.majabojarska.dev";
      description = "Home subdomain";
    };

    sp6catVm01HswroDomain = lib.mkOption {
      type = lib.types.str;
      default = "sp6cat-vm-01.hswro.majabojarska.dev";
      description = "sp6cat-vm-01.hswro subdomain";
    };
  };

  options.hosts = {
    sp6catVm01 = {
      storage = {
        wdUsbHddCryptName = lib.mkOption {
          type = lib.types.str;
          default = "crypt-wd-usb-hdd";
          description = "WD USB HDD crypt device name";
        };

        wdUsbHddMountPath = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/wd-usb-hdd";
          description = "WD USB HDD mount path";
        };
      };

      ports = {
        anubis-blog = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Anubis service port";
        };

        copyparty = lib.mkOption {
          type = lib.types.port;
          default = 8005;
          description = "Copyparty service port";
        };

        blog = lib.mkOption {
          type = lib.types.port;
          default = 8004;
          description = "Blog nginx service port";
        };

        fibo = lib.mkOption {
          type = lib.types.port;
          default = 8006;
          description = "Fibo service port";
        };

        redlib = lib.mkOption {
          type = lib.types.port;
          default = 8008;
          description = "Redlib service port";
        };

        anubis-redlib = lib.mkOption {
          type = lib.types.port;
          default = 8010;
          description = "Anubis Redlib service port";
        };

        anubis-copyparty = lib.mkOption {
          type = lib.types.port;
          default = 8011;
          description = "Anubis Copyparty service port";
        };

        anubis-uptime = lib.mkOption {
          type = lib.types.port;
          default = 8012;
          description = "Anubis Uptime Kuma service port";
        };

        anubis-grafana = lib.mkOption {
          type = lib.types.port;
          default = 8013;
          description = "Anubis Grafana service port";
        };

        anubis-vikunja = lib.mkOption {
          type = lib.types.port;
          default = 8014;
          description = "Anubis Vikunja service port";
        };

        anubis-searx = lib.mkOption {
          type = lib.types.port;
          default = 8015;
          description = "Anubis Searx service port";
        };

        uptimeKuma = lib.mkOption {
          type = lib.types.port;
          default = 8009;
          description = "Uptime Kuma service port";
        };

        prometheus = lib.mkOption {
          type = lib.types.port;
          default = 9090;
          description = "Prometheus service port";
        };

        prometheusMetrics = lib.mkOption {
          type = lib.types.port;
          default = 9090;
          description = "Prometheus metrics scrape port";
        };

        prometheusExporterNode = lib.mkOption {
          type = lib.types.port;
          default = 9100;
          description = "Prometheus Node Exporter service port";
        };

        prometheusExporterSmartctl = lib.mkOption {
          type = lib.types.port;
          default = 9101;
          description = "Prometheus Smartctl Exporter service port";
        };

        prometheusExporterZfs = lib.mkOption {
          type = lib.types.port;
          default = 9102;
          description = "Prometheus ZFS Exporter service port";
        };

        prometheusExporterChrony = lib.mkOption {
          type = lib.types.port;
          default = 9103;
          description = "Prometheus Chrony Exporter service port";
        };

        prometheusExporterFail2ban = lib.mkOption {
          type = lib.types.port;
          default = 9104;
          description = "Prometheus Fail2ban Exporter service port";
        };

        prometheusExporterWireguard = lib.mkOption {
          type = lib.types.port;
          default = 9105;
          description = "Prometheus WireGuard Exporter service port";
        };

        prometheusExporterPing = lib.mkOption {
          type = lib.types.port;
          default = 9106;
          description = "Prometheus Ping Exporter service port";
        };

        prometheusExporterPve = lib.mkOption {
          type = lib.types.port;
          default = 9221;
          description = "Prometheus PVE Exporter service port";
        };

        metricsTraefik = lib.mkOption {
          type = lib.types.port;
          default = 9107;
          description = "Prometheus Traefik metrics port";
        };

        grafana = lib.mkOption {
          type = lib.types.port;
          default = 3000;
          description = "Grafana service port";
        };

        ntfy = lib.mkOption {
          type = lib.types.port;
          default = 8090;
          description = "ntfy service port";
        };

        searx = lib.mkOption {
          type = lib.types.port;
          default = 7777;
          description = "Searx service port";
        };

        ollama = lib.mkOption {
          type = lib.types.port;
          default = 11434;
          description = "Ollama service port";
        };
      };
    };

    kube01 = {
      ports = {
        prometheusExporterNode = lib.mkOption {
          type = lib.types.port;
          default = 9100;
          description = "Prometheus Node Exporter service port";
        };

        prometheusExporterSmartctl = lib.mkOption {
          type = lib.types.port;
          default = 9101;
          description = "Prometheus Smartctl Exporter service port";
        };

        prometheusExporterZfs = lib.mkOption {
          type = lib.types.port;
          default = 9102;
          description = "Prometheus ZFS Exporter service port";
        };

        prometheusExporterFail2ban = lib.mkOption {
          type = lib.types.port;
          default = 9104;
          description = "Prometheus Fail2ban Exporter service port";
        };

        prometheusExporterPing = lib.mkOption {
          type = lib.types.port;
          default = 9106;
          description = "Prometheus Ping Exporter service port";
        };

        immich = lib.mkOption {
          type = lib.types.port;
          default = 8000;
          description = "Immich service port";
        };

        paperless = lib.mkOption {
          type = lib.types.port;
          default = 8001;
          description = "Paperless service port";
        };

        qbittorrent = lib.mkOption {
          type = lib.types.port;
          default = 8002;
          description = "qBittorrent service port";
        };
      };
    };
  };
}
