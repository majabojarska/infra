{ config, ... }:

{
  services.nginx.virtualHosts."majabojarska.dev" = {
    serverName = "majabojarska.dev";
    root = "/var/www/majabojarska.dev";

    locations."/" = {
      tryFiles = "$uri $uri/ /404.html =404";
      index = "index.html";
    };

    listen = [
      {
        addr = "127.0.0.1";
        port = 8004;
      }
    ];

    extraConfig = ''
      access_log /var/log/nginx/majabojarska.dev.access.log ;
      absolute_redirect off ;
    '';
  };


}