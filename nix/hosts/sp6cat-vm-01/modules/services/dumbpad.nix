{ config, ... }:
let
  dataPath = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/dumbpad";
in
{
  age.secrets = {
    "dumbpad.env" = {
      file = ../../secrets/dumbpad.env.age;
      mode = "0400";
      owner = "traefik";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.dumbpad = {
      image = "dumbwareio/dumbpad:latest@sha256:495a109141c28d990fedb9ed06e2d68db08a898b493479cdb12132d90f99d708";
      autoStart = true;
      autoRemoveOnStop = false;
      user = "1000:1000";

      ports = [
        "127.0.0.1:${toString config.hosts.sp6catVm01.ports.dumbpad}:3000"
      ];

      environment = {
        SITE_TITLE = "DumbPad";
        BASE_URL = "https://dumbpad.${config.globals.cloudDomain}";
      };

      environmentFiles = [
        config.age.secrets."dumbpad.env".path
      ];

      volumes = [
        "${dataPath}:/app/data"
      ];

      extraOptions = [
        "--health-cmd=curl -fsS http://127.0.0.1:3000 >/dev/null || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=5"
        "--health-start-period=15s"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0770 1000 1000 -"
    "z ${dataPath} 0770 1000 1000 -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.dumbpad = {
      rule = "Host(`dumbpad.${config.globals.cloudDomain}`)";
      service = "dumbpad";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "dumbpad.${config.globals.cloudDomain}";
          }
        ];
      };
    };

    services.dumbpad.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.dumbpad}";
        }
      ];
    };
  };
}
