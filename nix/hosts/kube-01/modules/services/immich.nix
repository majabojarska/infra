{
  pkgs,
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
        image = "ghcr.io/valkey-io/valkey:9.1.2-alpine3.24@sha256:48332870af354a799964c0012ae1194a0bf2bf894eb508f945810596dc2d8d11";
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
        image = "ghcr.io/immich-app/immich-machine-learning:v3.2.2@sha256:60dfcf266a9ef3b7376f5678e8c980d4fb61db5fc48c078fe8a326ab1535d60d";
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
        image = "ghcr.io/immich-app/immich-server:v3.2.2@sha256:79cc1623323d5894922686d8743b4780181428f98eecbfb58ce12c41ef02d1ea";
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

  systemd.services.docker-immich-network = {
    description = "Create Docker network for Immich";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    before = [
      "docker-immich-redis.service"
      "docker-immich-postgres.service"
      "docker-immich-machine-learning.service"
      "docker-immich-server.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect immich >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create immich >/dev/null'
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services = {
    docker-immich-redis = {
      requires = [ "docker-immich-network.service" ];
      after = [ "docker-immich-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-immich-postgres = {
      requires = [ "docker-immich-network.service" ];
      after = [ "docker-immich-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-immich-machine-learning = {
      requires = [ "docker-immich-network.service" ];
      after = [ "docker-immich-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-immich-server = {
      requires = [ "docker-immich-network.service" ];
      after = [ "docker-immich-network.service" ];
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
