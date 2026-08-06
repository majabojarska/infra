{ config, pkgs, ... }:
let
  audiomuseUid = 2110;
  audiomuseGid = 2110;
in
{
  age.secrets = {
    "audiomuse-db-pass" = {
      file = ../../secrets/audiomuse-db-pass.age;
      mode = "0400";
      owner = "audiomuse";
    };

    "audiomuse-secret-key" = {
      file = ../../secrets/audiomuse-secret-key.age;
      mode = "0400";
      owner = "audiomuse";
    };
  };

  users = {
    users.audiomuse = {
      isSystemUser = true;
      uid = audiomuseUid;
      group = "audiomuse";
      extraGroups = [ ];
      description = "Audiomuse AI user";
    };
    groups."audiomuse" = {
      gid = audiomuseGid;
    };
  };

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {

      audiomuse-redis = {
        image = "ghcr.io/valkey-io/valkey:9.0-alpine3.24";

        autoStart = true;

        environment = {
          TZ = config.time.timeZone;
        };

        # ports = [
        #   "6379:6379"
        # ];

        volumes = [
          "/storage/mirror/audiomuse/redis/data:/data"
        ];

        extraOptions = [
          "--network=audiomuse"
          "--restart=unless-stopped"
          "--user=${toString audiomuseUid}:${toString audiomuseGid}"
        ];
      };

      audiomuse-postgres = {
        image = "postgres:15-alpine";

        autoStart = true;

        environment = {
          TZ = config.time.timeZone;

          POSTGRES_USER = "audiomuse";
          POSTGRES_DB = "audiomusedb";
        };

        environmentFiles = [
          "/run/audiomuse/postgres.env"
        ];

        # ports = [
        #   "5432:5432"
        # ];

        volumes = [
          "/storage/mirror/audiomuse/postgres/data:/var/lib/postgresql/data"
        ];

        extraOptions = [
          "--network=audiomuse"
          "--restart=unless-stopped"
          "--user=${toString audiomuseUid}:${toString audiomuseGid}"
        ];
      };

      audiomuse-ai-flask = {
        image = "ghcr.io/neptunehub/audiomuse-ai:3.1.1";

        autoStart = true;

        ports = [
          "127.0.0.1:${toString config.hosts.kube01.ports.audiomuse}:8000"
        ];

        environment = {
          SERVICE_TYPE = "flask";

          TZ = config.time.timeZone;

          POSTGRES_USER = "audiomuse";
          POSTGRES_DB = "audiomusedb";
          POSTGRES_HOST = "audiomuse-postgres";
          POSTGRES_PORT = "5432";

          REDIS_URL = "redis://audiomuse-redis:6379/0";

          TEMP_DIR = "/app/temp_audio";
        };

        environmentFiles = [
          "/run/audiomuse/postgres.env"
        ];

        volumes = [
          "/storage/mirror/audiomuse/flask/plugins:/app/plugin/installed"
        ];

        tmpfs = {
          "/app/temp_audio" = "rw,size=512M";
        };

        dependsOn = [
          "audiomuse-redis"
          "audiomuse-postgres"
        ];

        extraOptions = [
          "--network=audiomuse"
          "--restart=unless-stopped"
          "--user=${toString audiomuseUid}:${toString audiomuseGid}"
        ];
      };

      audiomuse-ai-worker = {
        image = "ghcr.io/neptunehub/audiomuse-ai:latest";

        autoStart = true;

        environment = {
          SERVICE_TYPE = "worker";

          TZ = config.time.timeZone;

          POSTGRES_USER = "audiomuse";
          POSTGRES_DB = "audiomusedb";
          POSTGRES_HOST = "audiomuse-postgres";
          POSTGRES_PORT = "5432";

          REDIS_URL = "redis://audiomuse-redis:6379/0";

          TEMP_DIR = "/app/temp_audio";
        };

        environmentFiles = [
          "/run/audiomuse/postgres.env"
        ];

        volumes = [
          # "/storage/mirror/audiomuse/worker/temp_audio:/app/temp_audio"
          "/storage/mirror/audiomuse/worker/plugins:/app/plugin/installed"
        ];

        tmpfs = {
          "/app/temp_audio" = "rw,size=512M";
        };

        dependsOn = [
          "audiomuse-redis"
          "audiomuse-postgres"
        ];

        extraOptions = [
          "--network=audiomuse"
          "--restart=unless-stopped"
          "--user=${toString audiomuseUid}:${toString audiomuseGid}"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /storage/mirror/audiomuse 0700 audiomuse audiomuse -"
    "d /storage/mirror/audiomuse/redis/data 0700 audiomuse audiomuse -"
    "d /storage/mirror/audiomuse/postgres/data 0700 audiomuse audiomuse -"
    "d /storage/mirror/audiomuse/flask 0700 audiomuse audiomuse -"
    "d /storage/mirror/audiomuse/flask/plugins 0700 audiomuse audiomuse -"
    "d /storage/mirror/audiomuse/worker 0700 audiomuse audiomuse -"
    "d /storage/mirror/audiomuse/worker/plugins 0700 audiomuse audiomuse -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.audiomuse-ai = {
      rule = "Host(`audiomuse.${config.globals.homeDomain}`)";
      service = "audiomuse";
      # tls = {
      #   certResolver = "letsencrypt";
      #   domains = [
      #     {
      #       main = "audiomuse-ai.${config.globals.homeDomain}";
      #     }
      #   ];
      # };
    };

    services.audiomuse-ai.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.audiomuse}";
        }
      ];
    };
  };
}
