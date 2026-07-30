{ config, ... }:

{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        fibo = {
          image = "majabojarska/fibo:0.0.3";
          ports = [
            "127.0.0.1:${toString config.hosts.sp6catVm01.ports.fibo}:${toString config.hosts.sp6catVm01.ports.fibo}"
          ];
          environment = {
            POSTGRESS_PASSWORD = "password";
            FIBO_DEBUG = "false";
            FIBO_API_ADDR = "0.0.0.0:${toString config.hosts.sp6catVm01.ports.fibo}";
            FIBO_API_ROOT_URL = "https://fibo.${config.globals.cloudDomain}";
            FIBO_API_ALLOW_ORIGINS = "https://fibo.${config.globals.cloudDomain}";
            FIBO_METRICS_ENABLED = "true";
            FIBO_METRICS_ADDR = "0.0.0.0:${toString config.hosts.sp6catVm01.ports.fibo}";
            FIBO_METRICS_PATH = "/metrics";
            FIBO_LOGGING_LEVEL = "info";
          };
        };
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.fibo = {
      rule = "Host(`fibo.${config.globals.cloudDomain}`)";
      service = "fibo";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "fibo.${config.globals.cloudDomain}";
          }
        ];
      };
      middlewares = [
        "rate_limit"
        "fibo_redirect_swagger"
      ];
    };

    middlewares = {
      rate_limit.rateLimit = {
        average = 10;
        period = "1s";
        burst = 20;
      };

      fibo_redirect_swagger.redirectRegex = {
        regex = "^https://fibo\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}/(swagger)?$";
        replacement = "https://fibo.${config.globals.cloudDomain}/swagger/index.html";
      };
    };

    services.fibo.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.fibo}";
        }
      ];
    };
  };
}
