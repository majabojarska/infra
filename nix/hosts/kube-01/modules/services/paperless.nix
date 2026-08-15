{
  pkgs,
  config,
  ...
}:
let
  pathPaperless = "/storage/kubernetes/paperless/";
  pathData = "${pathPaperless}/data";
  pathConsume = "${pathPaperless}/consume";
  pathMedia = "${pathPaperless}/media";
  pathExport = "${pathPaperless}/export";

  # Adjust the endpoint once proper DNS records are set up.
  # The FQDN needs to resolve to a WG-routable IP address, otherwise Traefik will block the connection.
  ollamaEndpoint = "https://ollama.${config.globals.hswroDomain}";
in
{
  age.secrets = {
    "paperless-env" = {
      file = ../../secrets/paperless.env.age;
      mode = "0400";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      "paperless-broker" = {
        image = "ghcr.io/valkey-io/valkey:9.1-alpine3.24";
        autoStart = true;

        volumes = [
          "/var/lib/paperless/redis:/data"
        ];

        extraOptions = [
          "--network=paperless"
          "--health-cmd=redis-cli ping || exit 1"
          "--health-interval=10s"
          "--health-timeout=3s"
          "--health-retries=5"
          "--health-start-period=10s"
        ];
      };

      "paperless-webserver" = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:3.0.5";
        autoStart = true;

        dependsOn = [
          "paperless-broker"
          "paperless-gotenberg"
          "paperless-tika"
        ];

        ports = [
          "127.0.0.1:${toString config.hosts.kube01.ports.paperless}:8000"
        ];

        volumes = [
          "${pathData}:/usr/src/paperless/data"
          "${pathMedia}:/usr/src/paperless/media"
          "${pathConsume}:/usr/src/paperless/consume"
          "${pathExport}/export:/usr/src/paperless/export"
        ];

        environment = {
          # https://docs.paperless-ngx.com/configuration/
          PAPERLESS_URL = "https://paperless.${config.globals.homeDomain}";

          PAPERLESS_REDIS = "redis://paperless-broker:6379";

          PAPERLESS_DBENGINE = "sqlite";

          PAPERLESS_TIKA_ENABLED = "1";
          PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-gotenberg:3000";
          PAPERLESS_TIKA_ENDPOINT = "http://paperless-tika:9998";

          PAPERLESS_OCR_LANGUAGES = "pol eng";
          PAPERLESS_OCR_LANGUAGE = "pol+eng";
          PAPERLESS_OCR_DESKEW = "true";
          PAPERLESS_OCR_ROTATE_PAGES = "true";
          PAPERLESS_OCR_MODE = "auto";

          PAPERLESS_TIME_ZONE = config.time.timeZone;
          PAPERLESS_SESSION_COOKIE_AGE = toString (90 * 24 * 60 * 60); # 90 days in seconds
          PAPERLESS_NUMBER_OF_SUGGESTED_DATES = "42";

          PAPERLESS_OCR_USER_ARGS = builtins.toJSON {
            optimize = 2;
            pdfa_image_compression = "auto";
            jpeg_quality = 100;
            invalidate_digital_signatures = true;
          };

          PAPERLESS_AI_ENABLED = "true";
          PAPERLESS_AI_LLM_EMBEDDING_BACKEND = "ollama";
          PAPERLESS_AI_LLM_EMBEDDING_MODEL = "embeddinggemma";
          PAPERLESS_AI_LLM_EMBEDDING_ENDPOINT = ollamaEndpoint;

          PAPERLESS_AI_LLM_BACKEND = "ollama";
          PAPERLESS_AI_LLM_MODEL = "qwen3:1.7b";
          PAPERLESS_AI_LLM_ENDPOINT = ollamaEndpoint;

          PAPERLESS_LLM_INDEX_TASK_CRON = "0 22 * * 0";
        };

        environmentFiles = [
          config.age.secrets."paperless-env".path
        ];

        extraOptions = [
          "--network=paperless"
          "--health-cmd=curl -fsS http://127.0.0.1:8000 >/dev/null || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=20s"
        ];
      };

      "paperless-gotenberg" = {
        image = "docker.io/gotenberg/gotenberg:8.36";
        autoStart = true;

        cmd = [
          "gotenberg"
          "--chromium-disable-javascript=true"
          "--chromium-allow-list=file:///tmp/.*"
        ];

        extraOptions = [
          "--network=paperless"
          "--health-cmd=curl -fsS http://127.0.0.1:3000/health >/dev/null || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=10s"
        ];
      };

      "paperless-tika" = {
        image = "docker.io/apache/tika:3.3.1.0";
        autoStart = true;

        extraOptions = [
          "--network=paperless"
          "--health-cmd=bash -ec 'exec 3<>/dev/tcp/127.0.0.1/9998; printf \"GET / HTTP/1.1\\r\\nHost: localhost\\r\\nConnection: close\\r\\n\\r\\n\" >&3; head -n1 <&3 | grep -q \"200\"' || exit 1"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-retries=5"
          "--health-start-period=10s"
        ];
      };
    };
  };

  systemd.services.docker-paperless-network = {
    description = "Create Docker network for Paperless";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    before = [
      "docker-paperless-broker.service"
      "docker-paperless-webserver.service"
      "docker-paperless-gotenberg.service"
      "docker-paperless-tika.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect paperless >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create paperless >/dev/null'
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services = {
    docker-paperless-broker = {
      requires = [ "docker-paperless-network.service" ];
      after = [ "docker-paperless-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-paperless-webserver = {
      requires = [ "docker-paperless-network.service" ];
      after = [ "docker-paperless-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-paperless-gotenberg = {
      requires = [ "docker-paperless-network.service" ];
      after = [ "docker-paperless-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
    docker-paperless-tika = {
      requires = [ "docker-paperless-network.service" ];
      after = [ "docker-paperless-network.service" ];
      serviceConfig.Restart = "on-failure";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathPaperless} 0750 root root -"
    "d ${pathData} 0750 root root -"
    "d ${pathData}/index 0750 root root -"
    "d ${pathConsume} 0750 root root -"
    "d ${pathMedia} 0750 root root -"
    "d ${pathExport} 0750 root root -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.paperless = {
      rule = "Host(`paperless.${config.globals.homeDomain}`)";
      service = "paperless";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "paperless.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.paperless.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.paperless}";
        }
      ];
    };
  };

}
