{ ... }:
{
  virtualisation = {
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
}
