{ lib, ... }:

{
  options = {
    sp6catVm01 = {
      ports = {
        anubis-blog = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Anubis service port";
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

        nitter = lib.mkOption {
          type = lib.types.port;
          default = 8007;
          description = "Nitter service port";
        };

        redlib = lib.mkOption {
          type = lib.types.port;
          default = 8008;
          description = "Redlib service port";
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
      };

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
    };
  };

  imports = [
    ../../modules/i18n.nix
    ../../modules/globals.nix

    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/storage.nix
    ./modules/networking.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/system.nix
    ./modules/users.nix
  ];
}
