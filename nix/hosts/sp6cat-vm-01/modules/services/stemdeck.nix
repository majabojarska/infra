{ config, pkgs, ... }:
let
  dataPath = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/var/stemdeck";
  jobsPath = "${dataPath}/jobs";
  cachePath = "${dataPath}/cache";
in
{
  age.secrets."stemdeck-usersfile" = {
    file = ../../secrets/stemdeck-usersfile.age;
    mode = "0400";
    owner = "traefik";
    group = "traefik";
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.stemdeck = {
      image = "ghcr.io/stemdeckapp/stemdeck:0.15.2";
      autoStart = true;
      autoRemoveOnStop = false;

      ports = [
        "127.0.0.1:${toString config.hosts.sp6catVm01.ports.stemdeck}:8000"
      ];

      volumes = [
        "${jobsPath}:/app/jobs"
        "${cachePath}:/cache"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0770 root root -"
    "d ${jobsPath} 0770 root root -"
    "d ${cachePath} 0770 root root -"
    "z ${dataPath} 0770 root root -"
    "z ${jobsPath} 0770 root root -"
    "z ${cachePath} 0770 root root -"
  ];

  services.anubis.instances.stemdeck.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-stemdeck}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "stemdeck.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/stemdeck";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-stemdeck";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-stemdeck = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/stemdeck`)";
        service = "anubis-stemdeck";
        middlewares = [ "strip-anubis-stemdeck-prefix" ];
        priority = 200;
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [ { main = "anubis.${config.globals.cloudDomain}"; } ];
        };
      };

      anubis-stemdeck-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `stemdeck\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-stemdeck";
        priority = 300;
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [ { main = "anubis.${config.globals.cloudDomain}"; } ];
        };
      };

      stemdeck = {
        rule = "Host(`stemdeck.${config.globals.cloudDomain}`)";
        service = "stemdeck";
        middlewares = [
          "anubis-stemdeck"
          "stemdeck-basicauth"
        ];
        tls = {
          certResolver = "letsencrypt";
          domains = [ { main = "stemdeck.${config.globals.cloudDomain}"; } ];
        };
      };
    };

    middlewares = {
      stemdeck-basicauth.basicAuth = {
        usersFile = "${config.age.secrets."stemdeck-usersfile".path}";
      };

      anubis-stemdeck.forwardAuth = {
        address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-stemdeck}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024 * 1;
      };

      strip-anubis-stemdeck-prefix.stripPrefix.prefixes = [ "/stemdeck" ];
    };

    services = {
      anubis-stemdeck.loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-stemdeck}"; }
      ];
      stemdeck.loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.stemdeck}"; }
      ];
    };
  };
}
