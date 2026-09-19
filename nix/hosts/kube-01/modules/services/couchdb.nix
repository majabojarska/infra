{ config, ... }:
let
  pathPersistenceRoot = "/storage/mirror/services/couchdb";
  pathData = "${pathPersistenceRoot}/data";
  pathEtc = "${pathPersistenceRoot}/etc";
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.couchdb = {
      image = "couchdb:latest@sha256:8cf5f8442585c346d2717ff0ad95605731d2f19f67b8367840baa8d3b24ebc31";
      autoStart = true;
      autoRemoveOnStop = false;

      user = "5984:5984";

      environment = {
        TZ = config.time.timeZone;

        COUCHDB_USER = "admin";
        # TODO: load pass from age secret.
        COUCHDB_PASSWORD = "your-secure-password-here";
      };

      volumes = [
        "${pathData}:/opt/couchdb/data"
        "${pathEtc}/etc:/opt/couchdb/etc/local.d"
      ];

      ports = [
        "5984:5984"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathData} 0750 root root -"
    "d ${pathEtc} 0750 root root -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.couchdb = {
      rule = "Host(`couchdb.${config.globals.homeDomain}`)";
      service = "couchdb";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "couchdb.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.couchdb.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.couchdb}";
        }
      ];
    };
  };

}
