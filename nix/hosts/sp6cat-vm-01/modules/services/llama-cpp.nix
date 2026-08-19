{ config, pkgs, ... }:
let
  ollamaFQDN = "llm.${config.globals.hswroDomain}";

  pathOllamaRoot = "${config.hosts.sp6catVm01.storage.wdUsbHddMountPath}/ollama/";
  pathOllamaModels = "${pathOllamaRoot}/models";
  pathLlamaCppCache = "${pathOllamaRoot}/cache";

  qwenModelName = "Qwen3-1.7B-Q4_K_M.gguf";
  qwenModelPath = "${pathOllamaModels}/${qwenModelName}";
  qwenModelUrl = "https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/${qwenModelName}";
  qwenModelSha256 = "b139949c5bd74937ad8ed8c8cf3d9ffb1e99c866c823204dc42c0d91fa181897";

  gemmaModelName = "gemma-3-1b-it-Q4_K_M.gguf";
  gemmaModelPath = "${pathOllamaModels}/${gemmaModelName}";
  gemmaModelUrl = "https://huggingface.co/unsloth/gemma-3-1b-it-GGUF/resolve/main/${gemmaModelName}";
  gemmaModelSha256 = "8270790f3ab69fdfe860b7b64008d9a19986d8df7e407bb018184caa08798ebd";
in

{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.llama-cpp = {
      image = "ghcr.io/ggml-org/llama.cpp:server@sha256:343cdf1eba24193f448d8d00b0532bf0cbbc33801e642c6be73ffba491f37042";
      autoStart = true;

      ports = [
        "127.0.0.1:${toString config.hosts.sp6catVm01.ports.llama-cpp}:8080"
      ];

      environment = {
        TZ = config.time.timeZone;
        LLAMA_CACHE = "/cache";
      };

      volumes = [
        "${pathOllamaModels}:/models"
        "${pathLlamaCppCache}:/cache"
      ];

      cmd = [
        "--models-dir"
        "/models"
        "--host"
        "0.0.0.0"
        "--port"
        "8080"
        "--alias"
        "qwen3:1.7b"
        "--embeddings"
        "--parallel"
        "2"
      ];

      extraOptions = [
        "--memory-reservation=4g"
        "--memory=8g"
        "--health-cmd=curl -fsS http://127.0.0.1:8080/health >/dev/null || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=5"
        "--health-start-period=30s"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${pathOllamaRoot} 0750 root root -"
    "d ${pathOllamaModels} 0750 root root -"
    "d ${pathLlamaCppCache} 0750 root root -"
  ];

  systemd.services.llama-cpp-model-download = {
    description = "Download llama.cpp model to persistent models path";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-llama-cpp.service" ];
    serviceConfig.Type = "oneshot";
    path = [
      pkgs.curl
      pkgs.coreutils
    ];
    script = ''
      install -d -m 0750 ${pathOllamaModels}
      ensure_model() {
        local model_path="$1"
        local model_name="$2"
        local model_url="$3"
        local expected_sha="$4"

        if [ -s "$model_path" ] && echo "$expected_sha  $model_path" | sha256sum -c --status; then
          return 0
        fi

        local tmp_file
        tmp_file="$(mktemp ${pathOllamaModels}/."$model_name".tmp.XXXXXX)"
        curl -fL --retry 5 --retry-delay 2 --output "$tmp_file" "$model_url"
        if ! echo "$expected_sha  $tmp_file" | sha256sum -c --status; then
          rm -f "$tmp_file"
          echo "Checksum verification failed for $model_name" >&2
          exit 1
        fi
        install -m 0440 -T "$tmp_file" "$model_path"
        rm -f "$tmp_file"
      }

      ensure_model "${qwenModelPath}" "${qwenModelName}" "${qwenModelUrl}" "${qwenModelSha256}"
      ensure_model "${gemmaModelPath}" "${gemmaModelName}" "${gemmaModelUrl}" "${gemmaModelSha256}"
    '';
  };

  systemd.services.docker-llama-cpp = {
    requires = [ "llama-cpp-model-download.service" ];
    after = [ "llama-cpp-model-download.service" ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {

      llm = {
        rule = "Host(`${ollamaFQDN}`)";
        service = "llm";
        middlewares = [
          # "ollamaHost"
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
      # ollamaHost = {
      #   headers = {
      #     # customRequestHeaders = {
      #     #   Host = "127.0.0.1";
      #     # };
      #   };
      # };
    };

    services = {
      llm.loadBalancer = {
        servers = [
          {
            url = "http://127.0.0.1:${toString config.hosts.sp6catVm01.ports.llama-cpp}";
          }
        ];
      };
    };
  };
}
