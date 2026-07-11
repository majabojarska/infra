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
