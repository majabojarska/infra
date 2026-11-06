{ config, ... }:
let
  dataPath = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/cloudreve";
  network = "cloudreve";
  cloudrevePort = config.hosts.sp6catVm01.ports.cloudreve;
  anubisPort = config.hosts.sp6catVm01.ports.anubis-cloudreve;
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      cloudreve-postgresql = {
        image = "postgres:17";
        autoStart = true;
        autoRemoveOnStop = false;
        environment = {
          POSTGRES_USER = "cloudreve";
          POSTGRES_DB = "cloudreve";
          POSTGRES_HOST_AUTH_METHOD = "trust";
        };
        volumes = [
          "${dataPath}/postgresql:/var/lib/postgresql/data"
        ];
        extraOptions = [
          "--network=${network}"
          "--network-alias=postgresql"
        ];
      };

      cloudreve-redis = {
        image = "redis:latest";
        autoStart = true;
        autoRemoveOnStop = false;
        volumes = [
          "${dataPath}/redis:/data"
        ];
        extraOptions = [
          "--network=${network}"
          "--network-alias=redis"
        ];
      };

      cloudreve = {
        image = "cloudreve/cloudreve:v4";
        autoStart = true;
        autoRemoveOnStop = false;
        ports = [
          "127.0.0.1:${toString cloudrevePort}:5212"
        ];
        environment = {
          "CR_CONF_Database.Type" = "postgres";
          "CR_CONF_Database.Host" = "postgresql";
          "CR_CONF_Database.User" = "cloudreve";
          "CR_CONF_Database.Name" = "cloudreve";
          "CR_CONF_Database.Port" = "5432";
          "CR_CONF_Redis.Server" = "redis:6379";
        };
        volumes = [
          "${dataPath}/backend:/cloudreve/data"
        ];
        extraOptions = [
          "--network=${network}"
          "--health-cmd=curl -fsS http://127.0.0.1:5212 >/dev/null || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0750 root root -"
    "d ${dataPath}/backend 0770 root root -"
    "d ${dataPath}/postgresql 0700 999 999 -"
    "d ${dataPath}/redis 0770 999 999 -"
  ];

  services.anubis.instances.cloudreve.settings = {
    BIND = ":${toString anubisPort}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "cloudreve.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/cloudreve";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-cloudreve";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      anubis-cloudreve = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/cloudreve`)";
        service = "anubis-cloudreve";
        middlewares = [ "strip-anubis-cloudreve-prefix" ];
        priority = 200;
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [ { main = "anubis.${config.globals.cloudDomain}"; } ];
        };
      };

      anubis-cloudreve-callback = {
        rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `cloudreve\\.${
          builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
        }`)";
        service = "anubis-cloudreve";
        priority = 300;
        entrypoints = "websecure";
        tls = {
          certResolver = "letsencrypt";
          domains = [ { main = "anubis.${config.globals.cloudDomain}"; } ];
        };
      };

      # cloudreve = {
      #   rule = "Host(`cloudreve.${config.globals.cloudDomain}`)";
      #   service = "cloudreve";
      #   middlewares = [ "anubis-cloudreve" ];
      #   tls = {
      #     certResolver = "letsencrypt";
      #     domains = [ { main = "cloudreve.${config.globals.cloudDomain}"; } ];
      #   };
      # };
    };

    middlewares = {
      anubis-cloudreve.forwardAuth = {
        address = "http://127.0.0.1:${toString anubisPort}/.within.website/x/cmd/anubis/api/check";
        trustForwardHeader = true;
        maxResponseBodySize = 1024 * 1024;
      };
      strip-anubis-cloudreve-prefix.stripPrefix.prefixes = [ "/cloudreve" ];
    };

    services = {
      anubis-cloudreve.loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString anubisPort}"; }
      ];
      cloudreve.loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString cloudrevePort}"; }
      ];
    };
  };
}
