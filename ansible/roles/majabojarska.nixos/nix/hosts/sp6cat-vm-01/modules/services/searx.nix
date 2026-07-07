{ config, ... }:
{
  age.secrets = {
    "searx-env" = {
      file = ../../secrets/searx-env.age;
      mode = "0400";
    };
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = config.sp6catVm01.ports.searx;
        bind_address = "127.0.0.1";
        secret_key = "@SEARX_SECRET_KEY@";
      };
      search = {
        formats = [
          "html"
          "json"
        ];
      };
    };
    environmentFile = config.age.secrets."searx-env".path;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      searx = {
        rule = "Host(`search.${config.globals.cloudDomain}`)";
        service = "search";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "search.${config.globals.cloudDomain}";
            }
          ];
        };
        middlewares = [
          "rate_limit"
        ];
      };
    };

    services = {
      searx.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.sp6catVm01.ports.searx}";
          }
        ];
      };
    };
  };
}
