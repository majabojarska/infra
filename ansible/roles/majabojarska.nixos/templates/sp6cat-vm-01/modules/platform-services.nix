{ config, ... }:

{
  # services.borgbackup.repos = {
  #   baczek = {
  #     authorizedKeys = [
  #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILulC22JoRPoRtU5Q36cMzwo8W3DA2l58MUu9VcQEghw wint3rmute@thinkcentre"
  #     ];
  #     path = "/mnt/backup/baczek";
  #     quota = "100G";
  #     allowSubRepos = true;
  #   };
  #
  #   kube-01 = {
  #     authorizedKeys = [
  #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8itVsInt/KzsOTn1BqmjuDfgR5IIPuN4nT6g1JVrVt root@kube-01"
  #     ];
  #     path = "/mnt/backup/kube-01";
  #     quota = "220G";
  #     allowSubRepos = true;
  #   };

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
        email = "majabojarska98@gmail.com";
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
          rule = "Host(`anubis.cloud.majabojarska.dev`)";
          service = "anubis";
          entrypoints = "websecure";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "anubis.cloud.majabojarska.dev";
              }
            ];
          };
        };

        blog = {
          rule = "Host(`majabojarska.dev`)";
          service = "blog";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "majabojarska.dev";
              }
            ];
          };
          middlewares = [ "anubis" ];
        };

        copyparty = {
          rule = "Host(`copyparty.cloud.majabojarska.dev`)";
          service = "copyparty";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "copyparty.cloud.majabojarska.dev";
              }
            ];
          };
          middlewares = [ ];
        };

        fibo = {
          rule = "Host(`fibo.cloud.majabojarska.dev`)";
          service = "fibo";
          tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "fibo.cloud.majabojarska.dev";
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
            address = "http://127.0.0.1:8080/.within.website/x/cmd/anubis/api/check";
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
            regex = "^https://fibo\.cloud\.majabojarska\.dev/(swagger)?$";
            replacement = "https://fibo.cloud.majabojarska.dev/swagger/index.html";
          };
        };
      };

      services = {
        anubis.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:8080";
            }
          ];
        };

        blog.loadBalancer = {
          servers = [
            {
              url =
                "http://"
                + (builtins.elemAt config.services.nginx.virtualHosts."majabojarska.dev".listen 0).addr
                + ":"
                + builtins.toString
                  (builtins.elemAt config.services.nginx.virtualHosts."majabojarska.dev".listen 0).port;
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
              url = "http://127.0.0.1:8006";
            }
          ];
        };
      };
    };
  };

  services.anubis = {
    defaultOptions = {
      settings = {
        WEBMASTER_EMAIL = "majabojarska98@gmail.com";
        DIFFICULTY = 6;
      };

      botPolicy = {
        bots = [
          { import = "(data)/meta/default-config.yaml"; }
          { import = "(data)/bots/ai-catchall.yaml"; }
          { import = "(data)/bots/cloudflare-workers.yaml"; }
        ];
        status_codes = {
          CHALLENGE = 403;
          DENY = 403;
        };

        store.backend = "memory";

        thresholds = [
          {
            name = "no-suspicion";
            expression.all = [
              "weight < 10"
            ];
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 3;
            };
          }
          {
            name = "moderate-suspicion";
            expression.all = [
              "weight >= 10"
              "weight < 20"
            ];
            action = "CHALLENGE";
            challenge = {
              # https://anubis.techaro.lol/docs/admin/configuration/challenges/proof-of-work
              algorithm = "fast";
              difficulty = 4;
            };
          }
          {
            name = "mild-proof-of-work";
            expression.all = [
              "weight >= 20"
              "weight < 30"
            ];
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 5;
            };
          }
          {
            name = "extreme-suspicion";
            expression = "weight >= 30";
            action = "CHALLENGE";
            challenge = {
              algorithm = "fast";
              difficulty = 6;
            };
          }
        ];
      };
    };

    instances.blog.settings = {
      BIND = ":8080";
      BIND_NETWORK = "tcp";
      TARGET = " ";
      REDIRECT_DOMAINS = "majabojarska.dev";
      PUBLIC_URL = "https://anubis.cloud.majabojarska.dev";
      COOKIE_DOMAIN = "majabojarska.dev";
      DIFFICULTY = 20;
      SERVE_ROBOTS_TXT = true;
    };
  };

  # Blog
  services.nginx.enable = true;
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

  # https://github.com/9001/copyparty?tab=readme-ov-file#nixos-module
  services.copyparty = {
    enable = true;
    # the user to run the service as
    user = "copyparty";
    # the group to run the service as
    group = "copyparty";
    # directly maps to values in the [global] section of the copyparty config.
    # see `copyparty --help` for available options
    settings = {
      i = "127.0.0.1";
      # use lists to set multiple values
      p = [
        8005
      ];
      # use booleans to set binary flags
      no-reload = false;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
      xff-src = "127.0.0.1"; # IP of the reverse proxy
      xff-hdr = "x-forwarded-for"; # HTTP header containing the real client's IP
      rproxy = 1;
    };

    # create users
    accounts = {
      maja = {
        passwordFile = config.age.secrets."copyparty-pass-maja".path;
      };
      baczek = {
        passwordFile = config.age.secrets."copyparty-pass-baczek".path;
      };
    };

    # create a group
    groups = {
      admins = [
        "maja"
      ];
      users = [
        "maja"
        "baczek"
      ];
    };

    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };

  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = {
        fibo = {
          image = "majabojarska/fibo:0.0.3";
          ports = [
            "127.0.0.1:8006:8006"
          ];
          environment = {
            POSTGRESS_PASSWORD = "password";
            FIBO_DEBUG = "false";
            FIBO_API_ADDR = "0.0.0.0:8006";
            FIBO_API_ROOT_URL = "https://fibo.cloud.majabojarska.dev";
            FIBO_API_ALLOW_ORIGINS = "https://fibo.cloud.majabojarska.dev";
            FIBO_METRICS_ENABLED = "true";
            FIBO_METRICS_ADDR = "0.0.0.0:8006";
            FIBO_METRICS_PATH = "/metrics";
            FIBO_LOGGING_LEVEL = "info";
          };
        };
      };
    };
  };

  services.chrony = {
    enable = true;
    extraConfig = ''
      allow all
    '';
    servers = [
      "ntp2.301-moved.de" # Wuppertal
      "ntp2.rueckgr.at" # Nuremberg
      "stratum2-3.NTP.TechFak.Uni-Bielefeld.DE" # Bielefeld
      "time.hueske-edv.de" # Falkenstein
      "ntp0.hochstaetter.de" # Munich
    ];
  };
}
