{ hostname, port, ... }:
{ config, ... }:

{
  services.vikunja = {
    enable = true;
    frontendScheme = "http";
    frontendHostname = hostname;
    port = port;
    settings = {
      service = {
        # If enabled, Vikunja will send an email to everyone who is either
        # assigned to a task or created it when a task reminder is due.
        enableemailreminders = false;
        # Whether to let new users registering themselves or not
        enableregistration = false;
        # The maximum size clients will be able to request for user avatars.
        # If clients request a size bigger than this, it will be changed on the fly.
        maxavatarsize = 4096;
        # The duration of the issued JWT tokens in seconds.
        jwtttl = 2592000;
        # The duration of the "remember me" time in seconds. When the login request is
        # made with the long param set, the token returned will be valid for this period.
        jwtttllong = 25920000;
        maxitemsperpage = 100;
      };
    };
  };

  services.anubis.instances.vikunja.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-vikunja}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = config.services.vikunja.frontendHostname;
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/vikunja";
    COOKIE_DOMAIN = config.globals.cloudDomain;
    COOKIE_PREFIX = "anubis-vikunja";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };
}
