{ pkgs, ... }:

{
  users.groups = {
    kubernetes = {
      gid = 10001;
    };
    media = {
      gid = 10002;
    };
    immich = {
      gid = 10003;
    };
    openwebrx = {
      gid = 10004;
    };
    jellyfin = {
      gid = 10005;
    };
    arr = {
      gid = 10006;
    };
    zigbee = {
      gid = 10007;
    };
  };

  users.users = {
    # Human-like users
    maja = {
      isNormalUser = true;
      description = "maja";
      extraGroups = [
        "networkmanager"
        "wheel"
        "media"
        "kubernetes"
      ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBch2rzzVEnWcUbHJctteozpAFyJYXnd8wMC7DWXS9rL" # FP5

        # Akamai MBP
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNGBqGuCLlq5zZdOpjqK9z3g0uoWWmZEZdpLaF6I+V5orOjjBHDo5xJOLoR95PQlW2K4HG9TfOL7MzdndqMQwSUUycix1xWzytoy2XSpmWcXEHztsPBADcEdalfTcaPAIggPtUhGzQTkk4s31ripixtnfTs675ylPuRhiOWC+NNSYFDoAQNiwHL5+HIvdjL2jNGgYUQPUUL90fZcyBj6zOuSgTCU+zRxZtW+7aMhio0FeW8Rs/W4uVfQrDrFPU3d+Rnj9lU35/9UGUEY78rsPFPYxr5cqcDhCyyO0a8MX1so7nzxJB//RJOcBnUd5pUACxISHQ0Q8VYzT1nzPMsG6kOpGKml5KCdgenxMTVpc3is3/9A96C+Rnx4z1WuCTNj+85rJ1hfu40NnWzmytShl9lVQ1WqKcYVEcg8zIjIkKRBa/CFz2UzLtxQHSRoaoC0tk3UeaKBnrmuzyOL3vLEcYAh4C1kNze83uupTiRHK9xWFOZHY8c5loCzzGo2V+3nC20sS5JfFbaQbwdn4fcZzQNcK7wHo/vfDTH5JpbBLeEVFHxaTKG0MjRQgB3DdA/MaXDxNr4hxrzP+FSuhRfT4wnQA87CHJ5zF5RRn/jtUEfrBC80Y5ACOsWlNhpB8yMRY1goW/TmlCL3HOLlj1zl6uXTvaFJ9hinDKxpXX4bHjYQ=="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvfO8n2MZAT4bhdfV1AevvImyD1BcYPoim2EKirKiTVA5HuBm8tEFn2kKcB9FSq5nJVKC7tPtIQNO/fE7z0HSIPAxys1fRc1Z64dOb31KCSki4dkvPE8288+0tEaeOiCQM8JjMH5JrhZ1qwFovLBYXeA34isT14r04hl//xlJe4ujXp2P7TvUxf8HFUVzxVU9msa4gxhNrO/bsJTPWyuzfNoEY/WBI1FKqHn1COQK6+eC4MGZytZHnR+nFu/8X/vbNphwLQrfVQnmmc5IHF/C/Z9vWbrSa3hPA6VjzHxr+V5/b890gKajywMnpiTxOPuZcCnCC3h9iLTzaL4Q5ac2Uo5u/TY3XeeK8RexsCtouIz6mcL3u2AVtskZaMnwYKr284fsMnI7GCujOX9QzLW7206wzShn2/kEweMMHSOF8tInndWC9ElniYspNwFR6tWNlWq1FciU4PuKKl9bUSycJ3yhYb8QyvriL/RU5z1X+hv91o4kRUacnG98gXz3PaP4xE9wplkSTZ/2LrC7qiX5dYu+XVsNyNRbrZoa7rxbBIRdr+bH3wVGkmwvAlu/fCYqGM1NXvNJmR/dAr30hH1KhGqPDibWWK7I0eRh5cipC2zgCtb4cfMCIJF2W/34yWCptqyKx6J58TCbSPf3WRuCLbFydkV65Yb5MQtRprRLjHw=="
      ];
    };

    # Service users
    kubernetes = {
      isSystemUser = true;
      group = "kubernetes";
      uid = 10001;
      description = "Generic Kubernetes";
    };
    immich = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "immich";
      uid = 10003;
      description = "Immich";
      extraGroups = [
        "kubernetes"
        "video" # /dev/dri/cardX
        "render" # /dri/renderX
      ];
    };
    jellyfin = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "jellyfin";
      uid = 10005;
      description = "Jellyfin";
      extraGroups = [
        "kubernetes"
        "media"
        "video" # /dev/dri/cardX
        "render" # /dri/renderX
      ];
    };
    openwebrx = {
      isSystemUser = true;
      # isNormalUser = false;
      uid = 10004;
      group = "openwebrx";
      extraGroups = [ "plugdev" ];
    };
    arr = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "arr";
      uid = 10006;
      description = "Arr stack";
      extraGroups = [
        "kubernetes"
        "media"
      ];
    };
    zigbee = {
      isSystemUser = true;
      group = "zigbee";
      uid = 10007;
      description = "ZigBee";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "maja" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];
}
