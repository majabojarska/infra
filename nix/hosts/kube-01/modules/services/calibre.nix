{
  config,
  ...
}:
let
  pathCalibre = "/storage/mirror/calibre-web-automated";
  pathConfig = "${pathCalibre}/config";
  pathIngest = "${pathCalibre}/cwa-book-ingest";
  pathLibrary = "/storage/mirror/books";
in
{
  users = {
    users.calibre = {
      isSystemUser = true;
      group = "calibre";
      description = "Calibre-Web-Automated user";
    };

    groups.calibre = { };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.calibre-web-automated = {
      image = "crocodilestick/calibre-web-automated:latest@sha256:c31a738b6d5ec6982c050063dd3f063b6943eb1051fc81144789f840d9093a8d";
      autoStart = true;
      autoRemoveOnStop = false;

      ports = [
        "127.0.0.1:${toString config.hosts.kube01.ports.calibre}:8083"
      ];

      environment = {
        TZ = config.time.timeZone;
        PUID = toString config.users.users.calibre.uid;
        PGID = toString config.users.groups.calibre.gid;
        CWA_PORT_OVERRIDE = "8083";
      };

      volumes = [
        "${pathConfig}:/config"
        "${pathIngest}:/cwa-book-ingest"
        "${pathLibrary}:/calibre-library"
      ];

      extraOptions = [
        "--health-cmd=curl -fsS http://127.0.0.1:8083 >/dev/null || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=5"
        "--health-start-period=30s"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathCalibre} 0750 calibre calibre -"
    "d ${pathConfig} 0750 calibre calibre -"
    "d ${pathIngest} 0750 calibre calibre -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.calibre = {
      rule = "Host(`calibre.${config.globals.homeDomain}`)";
      service = "calibre";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "calibre.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.calibre.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.calibre}";
        }
      ];
    };
  };
}
