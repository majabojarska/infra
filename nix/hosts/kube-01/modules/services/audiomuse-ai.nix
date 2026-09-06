{
  config,
  pkgs,
  ...
}:
let
  dbUser = "audiomuse";
  dbName = "audiomuse";
  audiomuseRoot = "/storage/mirror/audiomuse";
in
{
  age.secrets = {
    "audiomuse.env" = {
      file = ../../secrets/audiomuse.env.age;
      mode = "0400";
    };

  };

  virtualisation.oci-containers = {

    containers = {

      audiomuse-postgres = {
        image = "postgres:15.19-alpine3.23@sha256:b0dc4a8dc256b963ee25867843d9fd366850e327e4a2a65ccb3c47262d092973";

        autoStart = true;

        environment = {
          TZ = config.time.timeZone;

          POSTGRES_USER = dbUser;
          POSTGRES_DB = dbName;
        };

        environmentFiles = [
          config.age.secrets."audiomuse.env".path
        ];

        volumes = [
          "${audiomuseRoot}/postgres/data:/var/lib/postgresql/data"
        ];

        extraOptions = [
          "--network=audiomuse"
          "--health-cmd=pg_isready -U ${dbUser} -d ${dbName} || exit 1"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=6"
          "--health-start-period=20s"
        ];
      };

      audiomuse-ai-flask = {
        image = "ghcr.io/neptunehub/audiomuse-ai:3.5.2@sha256:726d30981a601cb4556c6caece162ac15df247a7e7f09e36b64e8afd2f8f0b60";

        autoStart = true;

        ports = [
          "127.0.0.1:${toString config.hosts.kube01.ports.audiomuse}:8000"
        ];

        environment = {
          SERVICE_TYPE = "flask";

          TZ = config.time.timeZone;

          POSTGRES_USER = dbUser;
          POSTGRES_DB = dbName;
          POSTGRES_HOST = "audiomuse-postgres";
          POSTGRES_PORT = "5432";

          TEMP_DIR = "/app/temp_audio";
        };

        environmentFiles = [
          config.age.secrets."audiomuse.env".path
        ];

        volumes = [
          "${audiomuseRoot}/flask/plugins:/app/plugin/installed"
        ];

        dependsOn = [
          "audiomuse-postgres"
        ];

        extraOptions = [
          "--tmpfs=/app/temp_audio:rw,size=512M"
          "--network=audiomuse"
          "--health-cmd=curl -fsS http://127.0.0.1:8000 >/dev/null || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
      };

      audiomuse-ai-worker = {
        image = "ghcr.io/neptunehub/audiomuse-ai:3.5.2@sha256:726d30981a601cb4556c6caece162ac15df247a7e7f09e36b64e8afd2f8f0b60";

        autoStart = true;

        environment = {
          SERVICE_TYPE = "worker";

          TZ = config.time.timeZone;

          POSTGRES_USER = "audiomuse";
          POSTGRES_DB = "audiomuse";
          POSTGRES_HOST = "audiomuse-postgres";
          POSTGRES_PORT = "5432";

          TEMP_DIR = "/app/temp_audio";
        };

        environmentFiles = [
          config.age.secrets."audiomuse.env".path
        ];

        volumes = [
          "${audiomuseRoot}/worker/plugins:/app/plugin/installed"
        ];

        dependsOn = [
          "audiomuse-postgres"
        ];

        extraOptions = [
          "--tmpfs=/app/temp_audio:rw,size=512M"
          "--network=audiomuse"
          "--health-cmd=ps -ef | grep -q \"[p]ython.*worker\" || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${audiomuseRoot} 0700 root root -"
    "d ${audiomuseRoot}/postgres 0700 root root -"
    "d ${audiomuseRoot}/postgres/data 0700 root root -"
    "d ${audiomuseRoot}/flask 0700 root root -"
    "d ${audiomuseRoot}/flask/plugins 0700 root root -"
    "d ${audiomuseRoot}/worker 0700 root root -"
    "d ${audiomuseRoot}/worker/plugins 0700 root root -"
  ];

  systemd.services.docker-audiomuse-network = {
    description = "Create Docker network for Audiomuse";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    before = [
      "docker-audiomuse-postgres.service"
      "docker-audiomuse-ai-flask.service"
      "docker-audiomuse-ai-worker.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect audiomuse >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create audiomuse >/dev/null'
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services = {
    docker-audiomuse-postgres = {
      requires = [ "docker-audiomuse-network.service" ];
      after = [ "docker-audiomuse-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-audiomuse-ai-flask = {
      requires = [ "docker-audiomuse-network.service" ];
      after = [ "docker-audiomuse-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-audiomuse-ai-worker = {
      requires = [ "docker-audiomuse-network.service" ];
      after = [ "docker-audiomuse-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.audiomuse-ai = {
      rule = "Host(`audiomuse.${config.globals.homeDomain}`)";
      service = "audiomuse";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "audiomuse-ai.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.audiomuse.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.audiomuse}";
        }
      ];
    };
  };
}
