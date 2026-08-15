{
  pkgs,
  config,
  ...
}:
let
  pathConfigRoot = "/storage/kubernetes/qbittorrent";
  pathMedia = "/storage/media";
in
{
  users = {
    users.qbittorrent = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ ];
      description = "qBittorrent user";
    };

    groups.qbittorrent = { };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.qbittorrent = {
      image = "ghcr.io/linuxserver/qbittorrent:5.2.3@sha256:6816d2b144b1eb97665f886e41e18a14d026ba78c9d0953fc68a1211ea819433";
      autoStart = true;
      autoRemoveOnStop = false;

      ports = [
        "127.0.0.1:${toString config.hosts.kube01.ports.qbittorrent}:8080"
      ];

      environment = {
        TZ = config.time.timeZone;
        WEBUI_PORT = "8080";
        PUID = "${toString config.users.users.qbittorrent.uid}";
        PGID = "${toString config.users.groups.media.gid}";

        # Allow group write permissions for files created by qBittorrent
        # "media" group is used to allow other users (like "jellyfin") to RW these files.
        UMASK = "0007";
      };

      volumes = [
        "${pathConfigRoot}:/config"
        "${pathMedia}:${pathMedia}"
      ];

      extraOptions = [
        "--health-cmd=curl -fsS http://127.0.0.1:8080 >/dev/null || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=5"
        "--health-start-period=30s"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathConfigRoot} 0750 root root -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.qbittorrent = {
      rule = "Host(`qbittorrent.${config.globals.homeDomain}`)";
      service = "qbittorrent";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "qbittorrent.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.qbittorrent.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.qbittorrent}";
        }
      ];
    };
  };
}
