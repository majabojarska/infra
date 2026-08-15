{
  config,
  ...
}:
let
  pathJellyfin = "/storage/mirror/jellyfin";
  pathJellyfinCache = "${pathJellyfin}/cache";
  pathJellyfinConfig = "${pathJellyfin}/config";
  pathJellyfinData = "${pathJellyfin}/data";
  pathJellyfinLog = "${pathJellyfin}/log";

  pathMedia = "/storage/media";
  hwAccelDevice = "/dev/dri/renderD128";
in
{
  users = {
    users = {
      jellyfin = {
        isSystemUser = true;
        # isNormalUser = true;
        group = "jellyfin";
        uid = 10005;
        description = "Jellyfin user";
        extraGroups = [
          "kubernetes"
          "media"
          "video" # /dev/dri/cardX
          "render" # /dri/renderX
        ];
      };
    };

    groups.jellyfin = { };
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.jellyfin = {
      image = "jellyfin/jellyfin:10.11.11@sha256:aefb67e6a7ff1debdd154a78a7bbb780fd0c873d8639210a7f6a2016ad2b35db";
      autoStart = true;

      ports = [
        "127.0.0.1:${toString config.hosts.kube01.ports.jellyfin}:8096"
      ];

      environment = {
        TZ = config.time.timeZone;
        LIBVA_DRIVER_NAME = "iHD";
        JELLYFIN_CONFIG_DIR = "/etc/jellyfin";
        JELLYFIN_CACHE_DIR = "/var/cache/jellyfin";
        JELLYFIN_DATA_DIR = "/var/lib/jellyfin";
        JELLYFIN_LOG_DIR = "/var/log/jellyfin";
      };

      volumes = [
        "${pathJellyfinConfig}:/etc/jellyfin"
        "${pathJellyfinCache}:/var/cache/jellyfin"
        "${pathJellyfinData}:/var/lib/jellyfin"
        "${pathJellyfinLog}:/var/log/jellyfin"
        "${pathMedia}:${pathMedia}"
      ];

      extraOptions = [
        "--privileged" # Allow access to /dev/dri for hardware acceleration
        "--device=${hwAccelDevice}:${hwAccelDevice}"
        "--group-add=${toString config.users.groups.media.gid}"
        "--group-add=${toString config.users.groups.video.gid}"
        "--group-add=${toString config.users.groups.render.gid}"
        "--user=${toString config.users.users.jellyfin.uid}:${toString config.users.groups.jellyfin.gid}"
        "--health-cmd=curl -fsS http://127.0.0.1:8096 >/dev/null || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=5"
        "--health-start-period=30s"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathJellyfin} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinCache} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinConfig} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinData} 0750 jellyfin jellyfin -"
    "d ${pathJellyfinLog} 0750 jellyfin jellyfin -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.jellyfin = {
      rule = "Host(`jellyfin.${config.globals.homeDomain}`)";
      service = "jellyfin";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "jellyfin.${config.globals.homeDomain}";
          }
        ];
      };
    };

    services.jellyfin.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.kube01.ports.jellyfin}";
        }
      ];
    };
  };
}
