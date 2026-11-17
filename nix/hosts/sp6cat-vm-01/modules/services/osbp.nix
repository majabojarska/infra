{ config, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.osbp = {
      image = "majabojarska/omni-support-bundle-parser:latest@sha256:75527a506bece871cb41fee1428ac9bc94852dceeffb20e89559a014fb5696a1";
      autoStart = true;
      ports = [
        "127.0.0.1:${toString config.hosts.sp6catVm01.ports.osbp}:8080"
      ];
    };
  };

  services.anubis.instances.osbp.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-osbp}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "osbp.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/osbp";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-osbp";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-osbp = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/osbp`)";
        service = "anubis-osbp";
        middlewares = [ "strip-anubis-osbp-prefix" ];
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

      anubis-osbp-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `osbp\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}`)";
        service = "anubis-osbp";
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

      osbp = {
        rule = "Host(`osbp.${config.globals.cloudDomain}`)";
        service = "osbp";
        middlewares = [ "anubis-osbp" ];
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "osbp.${config.globals.cloudDomain}";
            }
          ];
        };
      };
    };

    middlewares = {
      anubis-osbp.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-osbp}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-osbp-prefix.stripPrefix.prefixes = [ "/osbp" ];
    };

    services = {
      anubis-osbp.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-osbp}";
          }
        ];
      };

      osbp.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.osbp}";
          }
        ];
      };
    };
  };
}
