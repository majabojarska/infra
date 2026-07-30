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

  };

}
