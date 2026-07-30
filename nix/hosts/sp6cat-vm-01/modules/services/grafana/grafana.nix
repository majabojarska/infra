{
  config,
  pkgs,
  lib,
  ...
}:
let
  healthchecks = import ../../../../../modules/healthchecks.nix { inherit lib pkgs; };
in
{
  age.secrets = {
    "grafana-secret-key" = {
      file = ../../../secrets/grafana-secret-key.age;
      mode = "0400";
      group = "grafana";
      owner = "grafana";
    };
    "grafana-admin-password" = {
      file = ../../../secrets/grafana-admin-password.age;
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
        http_port = config.hosts.sp6catVm01.ports.grafana;
        enforce_domain = true;
        enable_gzip = false; # Traefik will compress
        domain = "grafana.cloud.majabojarska.dev";
      };

      log = {
        level = "debug";
      };

      security = {
        secret_key = "$__file{${config.age.secrets."grafana-secret-key".path}}";

        admin_user = "admin";
        admin_password = "$__file{${config.age.secrets."grafana-admin-password".path}}";
      };

      analytics.reporting_enabled = false;
    };
    provision = {
      enable = true;

      datasources.settings = {
        datasources = [
          {
            name = "prometheus-sp6cat-vm-01";
            type = "prometheus";
            url = "http://localhost:${toString config.hosts.sp6catVm01.ports.prometheus}";
            isDefault = true;
          }
        ];

        # deleteDatasources = [
        #   {
        #     name = "Prometheus SP6CAT VM 01";
        #     orgId = 1;
        #   }
        # ];
      };

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

  services.anubis.instances.grafana.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-grafana}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "grafana.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/grafana";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-grafana";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
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
    "grafana-dashboards/traefik.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/17346/revisions/9/download";
        sha256 = "sha256-OtMp0nNxIPMvZ6qwg/JFtVTqXE7IN4/u5xlu9ruffak=";
      };
    };
    "grafana-dashboards/ping.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/18194/revisions/1/download";
        sha256 = "sha256-iRFzdPDqq2ytC5Sri7g1V0++AGOg5uCw+t/BwfVkSGY=";
      };
    };
    "grafana-dashboards/pve.json" = {
      user = "grafana";
      group = "grafana";
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/10347/revisions/5/download";
        sha256 = "sha256-rHtSUxuvD9ZWO4QZdC2AtzhDmtXbaBmqLLt7EcaFjv8=";
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-grafana = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/grafana`)";
        service = "anubis-grafana";
        middlewares = [ "strip-anubis-grafana-prefix" ];
        priority = 200;
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "anubis.${config.globals.cloudDomain}";
            }
          ];
        };
      };

      anubis-grafana-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `grafana\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-grafana";
        priority = 300;
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "anubis.${config.globals.cloudDomain}";
            }
          ];
        };
      };

      grafana = {
        rule = "Host(`grafana.${config.globals.cloudDomain}`)";
        service = "grafana";
        middlewares = [ "anubis-grafana" ];
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "grafana.${config.globals.cloudDomain}";
            }
          ];
        };
      };
    };

    middlewares = {
      anubis-grafana.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-grafana}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-grafana-prefix.stripPrefix.prefixes = [ "/grafana" ];
    };

    services = {
      anubis-grafana.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-grafana}";
          }
        ];
      };

      grafana.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.grafana}";
          }
        ];
      };
    };
  };

  system.preSwitchChecks = {
    grafanaLocalhostNoHttpError =
      # Grafana is sometimes slow to start, so we retry a few times before failing the switch
      healthchecks.curlHealthCheck {
        url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.grafana}";
        retryMaxTime = 30;
        retry = 10;
      };
  };

}
