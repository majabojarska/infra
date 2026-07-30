{ hostname, port, ... }:
{ config, ... }:

{
  services.vikunja = {
    enable = true;
    frontendScheme = "http";
    frontendHostname = hostname;
    port = port;
    settings = {
      service = {
        # If enabled, Vikunja will send an email to everyone who is either
        # assigned to a task or created it when a task reminder is due.
        enableemailreminders = false;
        # Whether to let new users registering themselves or not
        enableregistration = false;
        # The maximum size clients will be able to request for user avatars.
        # If clients request a size bigger than this, it will be changed on the fly.
        maxavatarsize = 4096;
        # The duration of the issued JWT tokens in seconds.
        jwtttl = 2592000;
        # The duration of the "remember me" time in seconds. When the login request is
        # made with the long param set, the token returned will be valid for this period.
        jwtttllong = 25920000;
        maxitemsperpage = 100;
      };
    };
  };

  services.anubis.instances.vikunja.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-vikunja}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = config.services.vikunja.frontendHostname;
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/vikunja";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-vikunja";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-vikunja = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/vikunja`)";
        service = "anubis-vikunja";
        middlewares = [ "strip-anubis-vikunja-prefix" ];
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

      anubis-vikunja-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `vikunja\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-vikunja";
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

      vikunja = {
        rule = "Host(`${config.services.vikunja.frontendHostname}`)";
        service = "vikunja";
        middlewares = [ "anubis-vikunja" ];
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = config.services.vikunja.frontendHostname;
            }
          ];
        };
      };
    };

    middlewares = {
      anubis-vikunja.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-vikunja}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-vikunja-prefix.stripPrefix.prefixes = [ "/vikunja" ];
    };

    services = {
      anubis-vikunja.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-vikunja}";
          }
        ];
      };

      vikunja.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.services.vikunja.port}";
          }
        ];
      };
    };
  };
}
