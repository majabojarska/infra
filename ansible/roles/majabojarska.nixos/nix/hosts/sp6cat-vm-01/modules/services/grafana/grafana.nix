{ config, pkgs, ... }:
{
  age.secrets = {
    "grafana-secret-key" = {
      file = ../../../secrets/grafana-secret-key.age;
      mode = "0400";
      group = "grafana";
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = config.sp6catVm01.ports.grafana;
        enforce_domain = true;
        enable_gzip = false; # Traefik will compress
        domain = "grafana.cloud.majabojarska.dev";
      };

      security = {
        secret_key = "$__file{${config.age.secrets."grafana-secret-key".path}}";
      };

      analytics.reporting_enabled = false;
    };
    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "prometheus-sp6cat-vm-01";
          type = "prometheus";
          url = "http://localhost:${toString config.sp6catVm01.ports.prometheus}";
          isDefault = true;
        }
      ];

      dashboards.settings = {
        apiVersion = 1;

        providers = [
          {
            name = "default";
            options.path = "/etc/grafana-dashboards";
          }
        ];
      };
    };

  };

  environment.etc = {
    "grafana-dashboards/node.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/1860/revisions/45/download";
        sha256 = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
      };
    };
    "grafana-dashboards/smartctl.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/22604/revisions/3/download";
        sha256 = "sha256-gpm/4rzcNv6br8L8cs9O6iWEScojfImWUi1uRXW8UpM=";
      };
    };
    "grafana-dashboards/chrony.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/19186/revisions/2/download";
        sha256 = "sha256-Etm7ZE7ISqh/w/HIxKAUOPJl5Sb+jRUneveuYfLOr0A=";
      };
    };
    "grafana-dashboards/wireguard.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/17251/revisions/1/download";
        sha256 = "sha256-+sCG6rhOnrz/GhRuQ3gr+D8bYyqAuQ7VTmuwo5ZVD48=";
      };
    };
    "grafana-dashboards/zfs.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/11364/revisions/2/download";
        sha256 = "sha256-8pNOiU5zm7dJu9yYuOku19jqcAH7NbrQ8q8x5xdXKjI=";
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      grafana = {
        rule = "Host(`grafana.${config.globals.cloudDomain}`)";
        service = "grafana";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "grafana.${config.globals.cloudDomain}";
            }
          ];
        };
        middlewares = [
          "rate_limit"
        ];
      };
    };

    services = {
      grafana.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.sp6catVm01.ports.grafana}";
          }
        ];
      };
    };
  };

  system.preSwitchChecks = {
    grafanaLocalhostNoHttpError = ''
      ${pkgs.curl}/bin/curl \
        --fail-with-body \
        --silent \
        --show-error \
          http://127.0.0.1:${toString config.sp6catVm01.ports.grafana} \
        >/dev/null
    '';
  };

}
