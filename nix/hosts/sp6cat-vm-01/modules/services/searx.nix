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
        port = config.hosts.sp6catVm01.ports.searx;
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

  services.anubis.instances.searx.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-searx}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "search.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/search";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-searx";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-searx = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/search`)";
        service = "anubis-searx";
        middlewares = [ "strip-anubis-searx-prefix" ];
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

      anubis-searx-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `search\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-searx";
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

      searx = {
        rule = "Host(`search.${config.globals.cloudDomain}`)";
        service = "searx";
        middlewares = [ "anubis-searx" ];
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "search.${config.globals.cloudDomain}";
            }
          ];
        };
      };
    };

    middlewares = {
      anubis-searx.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-searx}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-searx-prefix.stripPrefix.prefixes = [ "/search" ];
    };

    services = {
      anubis-searx.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-searx}";
          }
        ];
      };

      searx.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.services.searx.settings.server.port}";
          }
        ];
      };
    };
  };
}
