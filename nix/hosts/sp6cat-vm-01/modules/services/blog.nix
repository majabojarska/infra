{ config, pkgs, lib, ... }:
let
  healthchecks = import ../../../../modules/healthchecks.nix { inherit lib pkgs; };
in
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
        port = config.hosts.sp6catVm01.ports.blog;
      }
    ];

    extraConfig = ''
      access_log /var/log/nginx/${config.globals.baseDomain}.access.log ;
      absolute_redirect off ;
    '';
  };

  services.anubis.instances.blog.settings = {
    BIND = ":${toString config.hosts.sp6catVm01.ports.anubis-blog}";
    BIND_NETWORK = "tcp";
    TARGET = " ";
    REDIRECT_DOMAINS = config.globals.baseDomain;
    PUBLIC_URL = "https://anubis.${config.globals.cloudDomain}/blog";
    COOKIE_DOMAIN = config.globals.baseDomain;
    COOKIE_PREFIX = "anubis-blog";
    DIFFICULTY = 20;
    SERVE_ROBOTS_TXT = true;
  };

  system.preSwitchChecks = {
    blogLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.blog}";
    };

    blogDomainBlocksScrape = ''
      response=$(${pkgs.curl}/bin/curl \
        --silent \
        --write-out "%{response_code}" \
        --follow \
          https://${config.globals.baseDomain})

      if [[ "$response" != *Anubis* ]]; then
          echo "Expected the response to contain 'Anubis', got $response"
      fi

      if [[ ! "$response" =~ 403$ ]]; then
          echo "Expected 403 response code, got \$\{response\}"
      fi
    '';
  };
}
