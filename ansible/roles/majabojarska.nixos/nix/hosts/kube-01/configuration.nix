# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ lib, ... }:
{
  options = {
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

      };
    };
  };

  imports = [
    ../../modules/globals.nix

    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/system.nix
    ./modules/networking.nix
    ./modules/storage.nix
    ./modules/packages.nix
    ./modules/prometheus-exporters.nix
    ./modules/users.nix
    ./secrets.nix

    ./modules/k3s.nix
    ./modules/borgmatic.nix
  ];
}
