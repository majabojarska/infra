{
  pkgs,
  config,
  lib,
  ...
}:
let
  healthchecks = import ../../../../modules/healthchecks.nix { inherit lib pkgs; };
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.redlib = {
      image = "ghcr.io/majabojarska/redlib-docker:2026.9.6.0@sha256:a6c7a46dbc437ad8bb2f0b34b746a7ad1141e22b00e1d8be2a181cb2f405851f";
      autoStart = true;
      autoRemoveOnStop = false;

      ports = [
        "127.0.0.1:${toString config.hosts.sp6catVm01.ports.redlib}:8080"
      ];

      environment = {
        REDLIB_ADDRESS = "0.0.0.0";
        REDLIB_PORT = "8080";
        REDLIB_DEFAULT_THEME = "catppuccinMocha";
        REDLIB_DEFAULT_LAYOUT = "clean";
        REDLIB_DEFAULT_WIDE = "on";
        REDLIB_HOME_FROM_COLLECTIONS = "on";
      };

      extraOptions = [
        "--health-cmd=curl -fsS http://127.0.0.1:8080 >/dev/null || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=5"
        "--health-start-period=15s"
      ];
    };
  };

  services.anubis.instances.redlib.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-redlib}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "redlib.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/redlib";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-redlib";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-redlib = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/redlib`)";
        service = "anubis-redlib";
        middlewares = [ "strip-anubis-redlib-prefix" ];
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

      anubis-redlib-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `redlib\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-redlib";
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

      redlib = {
        rule = "Host(`redlib.${config.globals.cloudDomain}`)";
        service = "redlib";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "redlib.${config.globals.cloudDomain}";
            }
          ];
        };
        middlewares = [ "anubis-redlib" ];
      };
    };

    middlewares = {
      anubis-redlib.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-redlib}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-redlib-prefix.stripPrefix.prefixes = [ "/redlib" ];
    };

    services = {
      anubis-redlib.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-redlib}";
          }
        ];
      };

      redlib.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.redlib}";
          }
        ];
      };
    };
  };

  systemd = {
    services = {
      redlib-healthcheck = {
        description = "Healthcheck for Redlib";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '
              ${pkgs.curl}/bin/curl --fail --silent http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.redlib} \
                || ${pkgs.systemd}/bin/systemctl restart docker-redlib.service
            '
          '';
        };

      };
    };

    timers.redlib-healthcheck = {
      description = "Run myservice health check every minute";

      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "15min";
        Unit = "redlib-healthcheck.service";
      };
    };
  };

  system.preSwitchChecks = {
    redlibLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.redlib}";
    };

    redlibDomainBlocksScrape = ''
      response=$(${pkgs.curl}/bin/curl \
        --silent \
        --write-out "%{response_code}" \
        --follow \
          https://redlib.${config.globals.cloudDomain})

      if [[ "$response" != *Anubis* ]]; then
          echo "Expected the response to contain 'Anubis', got $response"
      fi

      if [[ ! "$response" =~ 403$ ]]; then
          echo "Expected 403 response code, got $response"
      fi
    '';
  };

}
