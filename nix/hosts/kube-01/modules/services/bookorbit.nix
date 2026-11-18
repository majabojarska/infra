{
  config,
  ...
}:
let
  pathBookOrbitRoot = "/storage/mirror/services/bookorbit";
  pathBooks = "${pathBookOrbitRoot}/books";
  pathAppData = "${pathBookOrbitRoot}/data";
  pathPostgres = "${pathBookOrbitRoot}/postgres";
  bookorbitUid = toString config.users.users.bookorbit.uid;
  bookorbitGid = toString config.users.groups.bookorbit.gid;
in
{
  age.secrets = {
    "bookorbit-env" = {
      file = ../../secrets/bookorbit.env.age;
      owner = "bookorbit";
      group = "bookorbit";
      mode = "0400";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      "bookorbit-app" = {
        image = "ghcr.io/bookorbit/bookorbit:latest@sha256:79cd9c66c990a82944514e3e82d5be5987f21eda96cb37a378ed1484043716fc";
        autoStart = true;
        user = "${bookorbitUid}:${bookorbitGid}";

        dependsOn = [
          "bookorbit-postgres"
        ];

        ports = [
          "127.0.0.1:${toString config.hosts.kube01.ports.bookorbit}:3000"
        ];

        environment = {
          NODE_ENV = "production";
          PORT = "3000";
          APP_URL = "https://books.${config.globals.homeDomain}";
          CLIENT_URL = "https://books.${config.globals.homeDomain}";
          POSTGRES_HOST = "bookorbit-postgres";
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";
          TZ = config.time.timeZone;
          LIBRARY_BROWSE_ROOT = "/books";
          DISABLE_LOCAL_AUTH = "false";
        };

        environmentFiles = [
          config.age.secrets."bookorbit-env".path
        ];

        volumes = [
          "${pathBooks}:/books"
          "${pathAppData}:/data"
        ];

        extraOptions = [
          "--network=bookorbit"
          "--read-only"
          "--tmpfs=/tmp"
          "--cap-drop=ALL"
          "--cap-add=CHOWN"
          "--cap-add=DAC_OVERRIDE"
          "--cap-add=FOWNER"
          "--cap-add=SETGID"
          "--cap-add=SETUID"
          "--security-opt=no-new-privileges:true"
          "--health-cmd=curl -fsS http://127.0.0.1:3000 >/dev/null || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
      };

      "bookorbit-postgres" = {
        image = "pgvector/pgvector:pg18@sha256:38681dc6eaf55308e2a4c6de392d131652dcfac70e1263e35cd9b5ea3fe39782";
        autoStart = true;
        user = "${bookorbitUid}:${bookorbitGid}";

        environment = {
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";
          PGDATA = "/var/lib/postgresql/data/pgdata";
        };

        environmentFiles = [
          config.age.secrets."bookorbit-env".path
        ];

        volumes = [
          "${pathPostgres}:/var/lib/postgresql/data"
        ];

        extraOptions = [
          "--network=bookorbit"
          "--health-cmd=pg_isready -U bookorbit -d bookorbit"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=20s"
        ];
      };
    };
  };

  systemd.services = {
    docker-bookorbit-app = {
      serviceConfig.Restart = "on-failure";
    };
    docker-bookorbit-postgres = {
      serviceConfig.Restart = "on-failure";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathBookOrbitRoot} 0750 ${bookorbitUid} ${bookorbitGid} -"
    "d ${pathBooks} 0750 ${bookorbitUid} ${bookorbitGid} -"
    "d ${pathAppData} 0750 ${bookorbitUid} ${bookorbitGid} -"
    "d ${pathPostgres} 0750 ${bookorbitUid} ${bookorbitGid} -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.bookorbit = {
      rule = "Host(`books.${config.globals.homeDomain}`)";
      service = "bookorbit";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "books.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.bookorbit.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.bookorbit}";
        }
      ];
    };
  };
}
