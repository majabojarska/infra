{
  config,
  ...
}:
let
  pathDocmost = "/storage/mirror/services/docmost";
  pathStorage = "${pathDocmost}/storage";
  pathPostgres = "${pathDocmost}/postgres";
  pathValkey = "${pathDocmost}/valkey";
in
{
  age.secrets."docmost-env" = {
    file = ../../secrets/docmost.env.age;
    mode = "0400";
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      docmost = {
        image = "docmost/docmost:0.98.0@sha256:c3bdc84767de0fc9431763523636ddfd783c35c25ef7d4a3c95c064628e78d7a";
        autoStart = true;
        dependsOn = [
          "docmost-db"
          "docmost-valkey"
        ];
        ports = [
          "127.0.0.1:${toString config.hosts.kube01.ports.docmost}:3000"
        ];
        environment = {
          APP_URL = "https://docmost.${config.globals.homeDomain}";
          REDIS_URL = "redis://docmost-valkey:6379";
        };
        environmentFiles = [ config.age.secrets."docmost-env".path ];
        volumes = [ "${pathStorage}:/app/data/storage" ];

        extraOptions = [
          "--network=docmost"
        ];
      };

      docmost-db = {
        # renovate: datasource=docker depName=docker.io/library/postgres allowedVersions=/^18$/
        image = "docker.io/library/postgres:18@sha256:eb63372c1e05c755f55fa30cbd07aecc443676fc6c0fa90b9002d01537841e1a";
        user = "${toString config.users.users."docmost-postgres".uid}:${
          toString config.users.groups."docmost-postgres".gid
        }";
        autoStart = true;
        environment = {
          POSTGRES_DB = "docmost";
          POSTGRES_USER = "docmost";
        };
        environmentFiles = [ config.age.secrets."docmost-env".path ];
        volumes = [ "${pathPostgres}:/var/lib/postgresql" ];
        extraOptions = [
          "--network=docmost"
          "--health-cmd=pg_isready -U docmost -d docmost"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
          "--health-start-period=10s"
        ];
      };

      docmost-valkey = {
        image = "ghcr.io/valkey-io/valkey:9.2.1-alpine3.24@sha256:3ad5a213cb1bc2fd4a113c89b6248a88655a6bf1dda69519d04e03cd3e3d2742";
        user = "${toString config.users.users."docmost-valkey".uid}:${
          toString config.users.groups."docmost-valkey".gid
        }";
        autoStart = true;
        cmd = [
          "valkey-server"
          "--appendonly"
          "yes"
          "--maxmemory-policy"
          "noeviction"
        ];
        volumes = [ "${pathValkey}:/data" ];
        extraOptions = [
          "--network=docmost"
          "--health-cmd=valkey-cli ping || exit 1"
          "--health-interval=10s"
          "--health-timeout=3s"
          "--health-retries=5"
          "--health-start-period=10s"
        ];
      };
    };
  };

  systemd.services = {
    docker-docmost.serviceConfig.Restart = "on-failure";
    docker-docmost-db.serviceConfig.Restart = "on-failure";
    docker-docmost-valkey.serviceConfig.Restart = "on-failure";
  };

  systemd.tmpfiles.rules = [
    "d ${pathDocmost} 0750 ${toString config.users.users.docmost.uid} ${toString config.users.groups.docmost.gid} -"
    "d ${pathStorage} 0750 ${toString config.users.users.docmost.uid} ${toString config.users.groups.docmost.gid} -"
    "d ${pathPostgres} 0750 ${toString config.users.users."docmost-postgres".uid} ${
      toString config.users.groups."docmost-postgres".gid
    } -"
    "d ${pathValkey} 0750 ${toString config.users.users."docmost-valkey".uid} ${
      toString config.users.groups."docmost-valkey".gid
    } -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.docmost = {
      rule = "Host(`docmost.${config.globals.homeDomain}`)";
      service = "docmost";
      tls = {
        certResolver = "letsencrypt";
        domains = [ { main = "docmost.${config.globals.homeDomain}"; } ];
      };
    };
    services.docmost.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.hosts.kube01.ports.docmost}"; }
    ];
  };
}
