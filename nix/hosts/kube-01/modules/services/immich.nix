{
  config,
  ...
}:
let
  pathImmichRoot = "/storage/kubernetes/immich/";
  pathImmichMedia = "${pathImmichRoot}/data";
  pathImmichPostgres = "${pathImmichRoot}/postgres";
  pathImmichModelCache = "${pathImmichRoot}/model-cache";
in
{
  age.secrets = {
    "immich-env" = {
      file = ../../secrets/immich.env.age;
      mode = "0400";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      "immich-redis" = {
        image = "ghcr.io/valkey-io/valkey:9.2.1-alpine3.24@sha256:3ad5a213cb1bc2fd4a113c89b6248a88655a6bf1dda69519d04e03cd3e3d2742";
        autoStart = true;

        extraOptions = [
          "--network=immich"
          "--health-cmd=redis-cli ping || exit 1"
          "--health-interval=10s"
          "--health-timeout=3s"
          "--health-retries=5"
          "--health-start-period=10s"
        ];
      };

      "immich-postgres" = {
        image = "ghcr.io/immich-app/postgres:17-vectorchord0.5.3@sha256:de30761f0081f2adcdcdb3fdcfa2d53aa73badb3712f943bf84eaffc8fc706af";
        autoStart = true;

        environment = {
          POSTGRES_USER = "immich";
          POSTGRES_DB = "immich";
          POSTGRES_INITDB_ARGS = "--data-checksums";
        };

        environmentFiles = [
          config.age.secrets."immich-env".path
        ];

        volumes = [
          "${pathImmichPostgres}:/var/lib/postgresql/data"
        ];

        extraOptions = [
          "--network=immich"
          "--shm-size=128m"
        ];
      };

      "immich-machine-learning" = {
        image = "ghcr.io/immich-app/immich-machine-learning:v3.4.2@sha256:739405742a79bd7447227c553bb62ed5491aa36acf00bc667af7f9c93b6fae91";
        autoStart = true;

        environment = {
          TZ = config.time.timeZone;
        };

        environmentFiles = [
          config.age.secrets."immich-env".path
        ];

        volumes = [
          "${pathImmichModelCache}:/cache"
        ];

        extraOptions = [
          "--network=immich"
          "--device=/dev/dri/renderD128"
        ];
      };

      "immich-server" = {
        image = "ghcr.io/immich-app/immich-server:v3.4.2@sha256:fc880c1bf665b4aab1e74c15e56ab871225989cd546536e6b77e771869af06bd";
        autoStart = true;

        dependsOn = [
          "immich-redis"
          "immich-postgres"
        ];

        ports = [
          "127.0.0.1:${toString config.hosts.kube01.ports.immich}:2283"
        ];

        volumes = [
          "${pathImmichMedia}:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];

        environment = {
          TZ = config.time.timeZone;
          DB_HOSTNAME = "immich-postgres";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";
          REDIS_HOSTNAME = "immich-redis";
          IMMICH_MACHINE_LEARNING_URL = "http://immich-machine-learning:3003";
        };

        environmentFiles = [
          config.age.secrets."immich-env".path
        ];

        extraOptions = [
          "--network=immich"
          "--device=/dev/dri/renderD128"
        ];
      };
    };
  };

  systemd.services = {
    docker-immich-redis = {
      serviceConfig.Restart = "on-failure";
    };
    docker-immich-postgres = {
      serviceConfig.Restart = "on-failure";
    };
    docker-immich-machine-learning = {
      serviceConfig.Restart = "on-failure";
    };
    docker-immich-server = {
      serviceConfig.Restart = "on-failure";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathImmichRoot} 0750 root root -"
    "d ${pathImmichMedia} 0750 root root -"
    "d ${pathImmichPostgres} 0750 root root -"
    "d ${pathImmichModelCache} 0750 root root -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.immich = {
      rule = "Host(`immich.${config.globals.homeDomain}`)";
      service = "immich";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "immich.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.immich.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.immich}";
        }
      ];
    };
  };
}
