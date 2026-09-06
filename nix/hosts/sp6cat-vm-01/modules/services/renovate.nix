{ pkgs, config, ... }:
{
  age.secrets = {
    "renovate-token" = {
      file = ../../secrets/renovate-token.age;
      mode = "0400";
      owner = "renovate";
      group = "renovate";
    };
    "renovate-github-com-token" = {
      file = ../../secrets/renovate-github-com-token.age;
      mode = "0400";
      owner = "renovate";
      group = "renovate";
    };
  };

  users = {
    users = {
      renovate = {
        isSystemUser = true;
        group = "renovate";
        description = "Renovate Bot";
        home = "/home/renovate";
        createHome = true;
        shell = pkgs.bashInteractive;
      };
    };
    groups = {
      renovate = { };
    };
  };

  services.renovate = {
    enable = true;
    schedule = "*:0/15";

    validateSettings = true;
    settings = {
      platform = "github";
      gitAuthor = "Renovate Bot <bot@renovateapp.com>";
      autodiscover = false;

      repositories = [
        "majabojarska/bitwarden-cli-docker"
        "majabojarska/bitwarden-cli-helm"
        "majabojarska/infra"
        # "majabojarska/OpenChocolate"
      ];

      prHourlyLimit = 50;
      prConcurrentLimit = 50;
      branchConcurrentLimit = 50;
      commitHourlyLimit = 200;
    };

    credentials = {
      RENOVATE_TOKEN = config.age.secrets."renovate-token".path;
      RENOVATE_GITHUB_COM_TOKEN = config.age.secrets."renovate-github-com-token".path;
    };

  };

  systemd.services.renovate.serviceConfig = {
    User = "renovate";
    Group = "renovate";
  };
}
