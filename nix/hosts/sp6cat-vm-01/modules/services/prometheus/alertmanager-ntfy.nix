{ config, ... }:
{
  age.secrets = {
    "alertmanager-ntfy-auth" = {
      file = ../../../secrets/alertmanager-ntfy-auth.age;
      mode = "0400";
    };
  };

  services.alertmanager-ntfy = {
    enable = true;
    settings = {
      http = {
        addr = "127.0.0.1:${toString config.hosts.sp6catVm01.ports.alertmanager-ntfy}";

      };
      ntfy = {
        baseurl = "https://ntfy.sh";
        notification = {
          topic = "alertmanager";
          priority = ''
            status == "firing" ? "high" : "default"
          '';
          tags = [
            {
              tag = "+1";
              condition = ''status == "resolved"'';
            }
            {
              tag = "rotating_light";
              condition = ''status == "firing"'';
            }
          ];
          templates = {
            title = ''{{ if eq .Status "resolved" }}Resolved: {{ end }}{{ index .Annotations "summary" }}'';
            description = ''{{ index .Annotations "description" }}'';
          };
        };
      };
    };
    extraSettingsPath = config.age.secrets."alertmanager-ntfy-auth".path;
  };

}
