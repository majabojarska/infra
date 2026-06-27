{ config, ... }:
{
  services.nitter = {
    enable = true;
    redisCreateLocally = true;
    openFirewall = false;
    settings = { };
    server.title = "fireshape";
    server.port = config.sp6catVm01.ports.nitter;
    server.https = true;
    server.hostname = "nitter.${config.globals.cloudDomain}";
    server.address = "127.0.0.1";
    preferences.hlsPlayback = true;
    preferences.autoplayGifs = false;
    config.tokenCount = 2;
  };

  services.redis.servers.nitter = {
    unixSocket = null;
  };

  systemd.services.nitter = {
    serviceConfig = {
      SocketBindAllow = "ipv4:tcp:${toString config.sp6catVm01.ports.nitter}";
      SocketBindDeny = "any";
    };
  };
}
