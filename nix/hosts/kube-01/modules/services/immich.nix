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
        image = "ghcr.io/valkey-io/valkey:9.1.1-alpine3.24@sha256:15568b9cb7eb67f4aed4de018c23f13d344e0e6437b31fe8fb8823dc81ebb3a9";
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
        image = "ghcr.io/immich-app/immich-machine-learning:v3.1.0@sha256:5a0839dc5303cd7215bcd2180a26aed3af41675aefb3e75e5157e9f10ad16e6e";
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
        image = "ghcr.io/immich-app/immich-server:v3.1.0@sha256:b434cb9287eea1471c9974845914d4dd328c9c2d652e446ed4930f99944f0ceb";
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
