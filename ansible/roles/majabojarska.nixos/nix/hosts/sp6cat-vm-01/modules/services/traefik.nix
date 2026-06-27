{ config, ... }:

{
  services.traefik = {
    enable = true;

    environmentFiles = [ config.age.secrets."traefik.env".path ];

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http3 = { };
          http.tls.certResolver = "letsencrypt";
          transport = {
            respondingTimeouts = {
              readTimeout = "0s";
            };
          };
        };

        # ntp = { address = ":123/udp"; };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        # Comment for prod
        # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
        email = config.globals.adminEmail;
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "ovh";
          disablePropagationCheck = true;
          delayBeforeCheck = 120;
        };
      };

      api.dashboard = false;
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      # api.insecure = true;
    };

    dynamicConfigOptions.http = {
      routers = {
        anubis = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`)";
          service = "anubis";
          entrypoints = "websecure";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "anubis.${config.globals.cloudDomain}";
              }
            ];
          };
        };

        blog = {
          rule = "Host(`${config.globals.baseDomain}`)";
          service = "blog";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = config.globals.baseDomain;
              }
            ];
          };
          middlewares = [ "anubis" ];
        };

        copyparty = {
          rule = "Host(`copyparty.${config.globals.cloudDomain}`)";
          service = "copyparty";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "copyparty.${config.globals.cloudDomain}";
              }
            ];
          };
          middlewares = [ ];
        };

        vikunja = {
          rule = "Host(`${config.services.vikunja.frontendHostname}`)";
          service = "vikunja";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = config.services.vikunja.frontendHostname;
              }
            ];
          };
        };

        fibo = {
          rule = "Host(`fibo.${config.globals.cloudDomain}`)";
          service = "fibo";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "fibo.${config.globals.cloudDomain}";
              }
            ];
          };
          middlewares = [
            "rate_limit"
            "fibo_redirect_swagger"
          ];
        };
      };

      middlewares = {
        anubis = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.sp6catVm01.ports.anubis}/.within.website/x/cmd/anubis/api/check";
          };
        };

        rate_limit = {
          rateLimit = {
            average = 10;
            period = "1s";
            burst = 20;
          };
        };

        fibo_redirect_swagger = {
          redirectRegex = {
            regex = "^https://fibo\\.${builtins.replaceStrings ["."] ["\\."] config.globals.cloudDomain}/(swagger)?$";
            replacement = "https://fibo.${config.globals.cloudDomain}/swagger/index.html";
          };
        };
      };

      services = {
        anubis.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.sp6catVm01.ports.anubis}";
            }
          ];
        };

        blog.loadBalancer = {
          servers = [
            {
              url =
                "http://"
                + (builtins.elemAt config.services.nginx.virtualHosts."${config.globals.baseDomain}".listen 0).addr
                + ":"
                +
                  builtins.toString
                    (builtins.elemAt config.services.nginx.virtualHosts."${config.globals.baseDomain}".listen 0).port;
            }
          ];
        };

        vikunja.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1" + ":" + builtins.toString (config.services.vikunja.port);
            }
          ];
        };

        copyparty.loadBalancer = {
          servers = [
            {
              url =
                "http://"
                + config.services.copyparty.settings.i
                + ":"
                + builtins.toString (builtins.elemAt config.services.copyparty.settings.p 0);
            }
          ];
        };

        fibo.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.sp6catVm01.ports.fibo}";
            }
          ];
        };
      };
    };
  };

}
