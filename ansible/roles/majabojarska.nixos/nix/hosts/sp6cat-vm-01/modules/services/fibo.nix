{ config, ... }:

{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        fibo = {
          image = "majabojarska/fibo:0.0.3";
          ports = [
            "127.0.0.1:${toString config.hosts.sp6catVm01.ports.fibo}:${toString config.hosts.sp6catVm01.ports.fibo}"
          ];
          environment = {
            POSTGRESS_PASSWORD = "password";
            FIBO_DEBUG = "false";
            FIBO_API_ADDR = "0.0.0.0:${toString config.hosts.sp6catVm01.ports.fibo}";
            FIBO_API_ROOT_URL = "https://fibo.${config.globals.cloudDomain}";
            FIBO_API_ALLOW_ORIGINS = "https://fibo.${config.globals.cloudDomain}";
            FIBO_METRICS_ENABLED = "true";
            FIBO_METRICS_ADDR = "0.0.0.0:${toString config.hosts.sp6catVm01.ports.fibo}";
            FIBO_METRICS_PATH = "/metrics";
            FIBO_LOGGING_LEVEL = "info";
          };
        };
      };
    };
  };
}
