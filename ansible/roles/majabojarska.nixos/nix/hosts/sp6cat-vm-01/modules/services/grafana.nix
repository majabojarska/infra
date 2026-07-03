{ config, ... }:
{
  age.secrets = {
    "grafana-secret-key" = {
      file = ../../secrets/grafana-secret-key.age;
      mode = "0400";
      group = "grafana";
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = config.sp6catVm01.ports.grafana;
        enforce_domain = true;
        enable_gzip = false; # Traefik will compress
        domain = "grafana.cloud.majabojarska.dev";
      };

      security = {
        secret_key = "$__file{${config.age.secrets."grafana-secret-key".path}}";
      };

      analytics.reporting_enabled = false;
    };
  };
}
