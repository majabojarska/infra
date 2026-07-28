{ config, ... }:

{
  age.secrets = {
    "traefik.env" = {
      file = ../../secrets/traefik.age;
      mode = "0400";
      owner = "traefik";
    };
  };

  services.traefik = {
    enable = true;

    environmentFiles = [ config.age.secrets."traefik.env".path ];

    staticConfigOptions = {
      metrics = {
        prometheus = {
          addEntryPointsLabels = true;
          addServicesLabels = true;
          addRoutersLabels = true;

          entryPoint = "metrics";
        };
      };

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

        metrics = {
          address = "127.0.0.1:${toString config.hosts.sp6catVm01.ports.metricsTraefik}";
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

        anubis-redlib = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/redlib`)";
          service = "anubis-redlib";
          middlewares = [ "strip-anubis-redlib-prefix" ];
          priority = 110;
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

        anubis-redlib-callback = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `redlib\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}`)";
          service = "anubis-redlib";
          priority = 120;
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

        anubis-copyparty = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/copyparty`)";
          service = "anubis-copyparty";
          middlewares = [ "strip-anubis-copyparty-prefix" ];
          priority = 130;
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

        anubis-copyparty-callback = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `copyparty\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}`)";
          service = "anubis-copyparty";
          priority = 140;
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

        anubis-uptime = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/uptime`)";
          service = "anubis-uptime";
          middlewares = [ "strip-anubis-uptime-prefix" ];
          priority = 150;
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

        anubis-uptime-callback = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `uptime\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}`)";
          service = "anubis-uptime";
          priority = 160;
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

        anubis-grafana = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/grafana`)";
          service = "anubis-grafana";
          middlewares = [ "strip-anubis-grafana-prefix" ];
          priority = 170;
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

        anubis-grafana-callback = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `grafana\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}`)";
          service = "anubis-grafana";
          priority = 180;
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

        anubis-vikunja = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/vikunja`)";
          service = "anubis-vikunja";
          middlewares = [ "strip-anubis-vikunja-prefix" ];
          priority = 190;
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

        anubis-vikunja-callback = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/.within.website/`) && QueryRegexp(`redir`, `vikunja\\.${builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain}`)";
          service = "anubis-vikunja";
          priority = 200;
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

        anubis-blog = {
          rule = "Host(`anubis.${config.globals.cloudDomain}`) && PathPrefix(`/blog`)";
          service = "anubis";
          middlewares = [ "strip-anubis-blog-prefix" ];
          priority = 100;
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
          middlewares = [ "anubis-blog" ];
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
          middlewares = [ "anubis-copyparty" ];
        };

        vikunja = {
          rule = "Host(`${config.services.vikunja.frontendHostname}`)";
          service = "vikunja";
          middlewares = [ "anubis-vikunja" ];
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

        redlib = {
          rule = "Host(`redlib.${config.globals.cloudDomain}`)";
          service = "redlib";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "redlib.${config.globals.cloudDomain}";
              }
            ];
          };
          middlewares = [ "anubis-redlib" ];
        };

        uptimeKuma = {
          rule = "Host(`uptime.${config.globals.cloudDomain}`)";
          service = "uptimeKuma";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "uptime.${config.globals.cloudDomain}";
              }
            ];
          };
          middlewares = [ "anubis-uptime" ];
        };

      };

      middlewares = {
        anubis-blog = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-blog}/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
            maxResponseBodySize = 1024 * 1024 * 1;
          };
        };

        anubis-redlib = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-redlib}/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
            maxResponseBodySize = 1024 * 1024 * 1;
          };
        };

        anubis-copyparty = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-copyparty}/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
            maxResponseBodySize = 1024 * 1024 * 1;
          };
        };

        anubis-uptime = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-uptime}/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
            maxResponseBodySize = 1024 * 1024 * 1;
          };
        };

        anubis-grafana = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-grafana}/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
            maxResponseBodySize = 1024 * 1024 * 1;
          };
        };

        anubis-vikunja = {
          forwardAuth = {
            address = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-vikunja}/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
            maxResponseBodySize = 1024 * 1024 * 1;
          };
        };

        strip-anubis-blog-prefix = {
          stripPrefix.prefixes = [ "/blog" ];
        };

        strip-anubis-redlib-prefix = {
          stripPrefix.prefixes = [ "/redlib" ];
        };

        strip-anubis-copyparty-prefix = {
          stripPrefix.prefixes = [ "/copyparty" ];
        };

        strip-anubis-uptime-prefix = {
          stripPrefix.prefixes = [ "/uptime" ];
        };

        strip-anubis-grafana-prefix = {
          stripPrefix.prefixes = [ "/grafana" ];
        };

        strip-anubis-vikunja-prefix = {
          stripPrefix.prefixes = [ "/vikunja" ];
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
            regex = "^https://fibo\\.${
              builtins.replaceStrings [ "." ] [ "\\." ] config.globals.cloudDomain
            }/(swagger)?$";
            replacement = "https://fibo.${config.globals.cloudDomain}/swagger/index.html";
          };
        };
      };

      services = {
        anubis.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-blog}";
            }
          ];
        };

        anubis-redlib.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-redlib}";
            }
          ];
        };

        anubis-copyparty.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-copyparty}";
            }
          ];
        };

        anubis-uptime.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-uptime}";
            }
          ];
        };

        anubis-grafana.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-grafana}";
            }
          ];
        };

        anubis-vikunja.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.anubis-vikunja}";
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
                  toString
                    (builtins.elemAt config.services.nginx.virtualHosts."${config.globals.baseDomain}".listen 0).port;
            }
          ];
        };

        vikunja.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1" + ":" + toString (config.services.vikunja.port);
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
                + toString (builtins.elemAt config.services.copyparty.settings.p 0);
            }
          ];
        };

        fibo.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.fibo}";
            }
          ];
        };

        redlib.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.redlib}";
            }
          ];
        };

        uptimeKuma.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.uptimeKuma}";
            }
          ];
        };
      };
    };
  };

}
