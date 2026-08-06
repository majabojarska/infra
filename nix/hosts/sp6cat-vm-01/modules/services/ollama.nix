{ config, pkgs, ... }:
let
  pathOllamaModels = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/ollama-models";
  ollamaFQDN = "ollama.${config.globals.hswroDomain}";
in

{
  users = {
    users.ollama = {
      isSystemUser = true;
      description = "Ollama user";
      extraGroups = [ "ollama" ];
      createHome = true;
      home = pathOllamaModels;
      group = "ollama";
    };

    groups.ollama = { };
  };

  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = config.hosts.sp6catVm01.ports.ollama;
    package = pkgs.ollama-cpu;
    models = pathOllamaModels;
    loadModels = [
      "embeddinggemma"
      "qwen3:1.7b"
    ];

    # Prevent Ollama from trying to keep too many models in memory at once, which can cause OOM errors.
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "2";
      OLLAMA_MAX_LOADED_MODELS = "2";
      OLLAMA_KEEP_ALIVE = "15m";
    };
  };

  systemd.services.ollama.serviceConfig = {
    User = "ollama";
    Group = "ollama";

    MemoryHigh = "4G";
    MemoryMax = "4500M";

    Environment = [
      "OLLAMA_MODELS=${pathOllamaModels}"
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${pathOllamaModels} 0750 ollama ollama -"
    "d ${pathOllamaModels}/blobs 0750 ollama ollama -"
    "d ${pathOllamaModels}/manifests 0750 ollama ollama -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers = {

      ollama = {
        rule = "Host(`${ollamaFQDN}`)";
        service = "ollama";
        middlewares = [
          "ollamaHost"
          "privateNetworksOnly"
        ];
        tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = ollamaFQDN;
            }
          ];
        };
      };
    };

    middlewares = {
      privateNetworksOnly = {
        ipAllowList = {
          sourceRange = [
            "192.168.0.0/16" # Private networks
            "10.0.0.0/8" # WG
          ];
        };
      };

      # Otherwise Ollama 403s out
      ollamaHost = {
        headers = {
          customRequestHeaders = {
            Host = "127.0.0.1";
          };
        };
      };
    };

    services = {
      ollama.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.services.ollama.port}";
          }
        ];
      };
    };
  };
}
