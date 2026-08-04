{
  # pkgs,
  pkgs_unstable,
  config,
  ...
}:
let
  pathProfile = "/storage/kubernetes/qbittorrent";
in
{
  users = {
    users.qbittorrent = {
      isSystemUser = true;
      extraGroups = [ "media" ];
      group = "qbittorrent";
      description = "qBittorrent user";
    };

    groups.qbittorrent = { };
  };

  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    webuiPort = config.hosts.kube01.ports.qbittorrent;
    profileDir = pathProfile;
    openFirewall = false;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = "admin";

          # https://codeberg.org/feathecutie/qbittorrent_password
          #
          # The password was hashed using PBKDF2 with SHA256, 10000 iterations, and a 16-byte salt.
          # It's generally safe to keep in a public repo in this scenario, especially as this is a LAN-only service.
          Password_PBKDF2 = "@ByteArray(UWTpBxHb8Ab7ff0E5n26Gw==:HILQ74B+nOxtZksOxeUWp0dPwyYFy5T2+fbj7qqLgz7U9jrVVIrs5rAPz3IcDb0v15hyAT7Z3D8KEZeY9CBC1Q==)";
        };
        LegalNotice.Accepted = true;
        General.Locale = "en";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathProfile} 0750 qbittorrent qbittorrent -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.qbittorrent = {
      rule = "Host(`qbittorrent.${config.globals.cloudDomain}`)";
      service = "qbittorrent";
      tls = {
        certResolver = "letsencrypt";
        domains = [
          {
            main = "qbittorrent.${config.globals.cloudDomain}";
          }
        ];
      };
    };

    services.qbittorrent.loadBalancer = {
      servers = [
        {
          url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.qbittorrent}";
        }
      ];
    };
  };
}
