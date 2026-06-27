{ config, ... }:

{
  services.nginx.virtualHosts."${config.globals.baseDomain}" = {
    serverName = config.globals.baseDomain;
    root = "/var/www/${config.globals.baseDomain}";

    locations."/" = {
      tryFiles = "$uri $uri/ /404.html =404";
      index = "index.html";
    };

    listen = [
      {
        addr = "127.0.0.1";
        port = config.sp6catVm01.ports.blog;
      }
    ];

    extraConfig = ''
      access_log /var/log/nginx/${config.globals.baseDomain}.access.log ;
      absolute_redirect off ;
    '';
  };
}
