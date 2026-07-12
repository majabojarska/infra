{ config, ... }:
{
  age.secrets = {
    "ntfy-auth" = {
      file = ../../secrets/ntfy-auth.age;
      mode = "0400";
      owner = "ntfy-sh";
      group = "ntfy-sh";
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      # Network
      listen-http = "127.0.0.1:${toString config.hosts.sp6catVm01.ports.ntfy}";
      base-url = "https://ntfy.${config.globals.cloudDomain}";
      upstream-base-url = "https://ntfy.sh";
      behind-proxy = true;

      # Auth
      # auth-file = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/ntfy/auth.db";
      auth-default-access = "deny-all";
      enable-login = true;
      require-login = true;

      # Messages
      # attachment-cache-dir = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/ntfy/attachments";
      attachment-file-size-limit = "20M";
      attachment-total-size-limit = "1G";
      attachment-expiry-duration = "12h";
      # cache-file = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/ntfy/cache.db";
    };
    # Auth users and tokens are loaded through the env file
    environmentFile = config.age.secrets."ntfy-auth".path;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      ntfy = {
        rule = "Host(`ntfy.${config.globals.cloudDomain}`)";
        service = "ntfy";
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = "ntfy.${config.globals.cloudDomain}";
            }
          ];
        };
        middlewares = [
          "rate_limit"
        ];
      };
    };

    services = {
      ntfy.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.ntfy}";
          }
        ];
      };
    };
  };
}
