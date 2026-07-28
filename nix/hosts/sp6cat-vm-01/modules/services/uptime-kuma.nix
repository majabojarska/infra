{ config, ... }:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = toString config.hosts.sp6catVm01.ports.uptimeKuma;
    };
  };

  services.anubis.instances.uptimeKuma.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-uptime}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = "uptime.${config.globals.cloudDomain}";
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/uptime";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-uptime";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };
}
