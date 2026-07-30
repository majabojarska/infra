{ config, ... }:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = toString config.hosts.sp6catVm01.ports.uptimeKuma;
    };
  };

  services.anubis.instances.uptimeKuma.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-uptime}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "uptime.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/uptime";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-uptime";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-uptime = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/uptime`)";
        service = "anubis-uptime";
        middlewares = [ "strip-anubis-uptime-prefix" ];
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

      anubis-uptime-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `uptime\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-uptime";
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

      uptimeKuma = {
        rule = "Host(`uptime.${config.globals.cloudDomain}`)";
        service = "uptimeKuma";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "uptime.${config.globals.cloudDomain}";
            }
          ];
        };
        middlewares = [ "anubis-uptime" ];
      };
    };

    middlewares = {
      anubis-uptime.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-uptime}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-uptime-prefix.stripPrefix.prefixes = [ "/uptime" ];
    };

    services = {
      anubis-uptime.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-uptime}";
          }
        ];
      };

      uptimeKuma.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.uptimeKuma}";
          }
        ];
      };
    };
  };
}
