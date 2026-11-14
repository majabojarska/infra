{ config, lib, ... }:

let
  renovateRepositories = [
    "majabojarska/bitwarden-cli-docker"
    "majabojarska/bitwarden-cli-helm"
    "majabojarska/infra"
    # "majabojarska/OpenChocolate"
    "majabojarska/redlib-docker"
  ];

in
{
  users = {
    users.renovate = {
      isSystemUser = true;
      group = "renovate";
      description = "Renovate Bot";
    };
    groups.renovate = { };
  };

  age.secrets."renovate-env" = {
    file = ../../secrets/renovate-env.age;
    mode = "0400";
    owner = "renovate";
    group = "renovate";
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.renovate = {
      image = "renovate/renovate:44.239@sha256:7dba1a3b916a2cf302ba0df458ddcc8fcbac3c92d0fe9882ac13ba0363de656b";
      autoStart = true;
      user = "${toString config.users.users.renovate.uid}:${toString config.users.groups.renovate.gid}";
      environmentFiles = [
        config.age.secrets."renovate-env".path
      ];
      environment = {
        TZ = config.time.timeZone;
        LOG_LEVEL = "info";

        RENOVATE_PLATFORM = "github";
        RENOVATE_AUTODISCOVER = "false";
        RENOVATE_REPOSITORIES = lib.concatStringsSep "," renovateRepositories;
        RENOVATE_GIT_AUTHOR = "Renovate Bot <bot@renovateapp.com>";
        RENOVATE_PR_HOURLY_LIMIT = "50";
        RENOVATE_PR_CONCURRENT_LIMIT = "50";
        RENOVATE_BRANCH_CONCURRENT_LIMIT = "50";
        RENOVATE_COMMIT_HOURLY_LIMIT = "200";
        RENOVATE_INTERNAL_CHECKS_FILTER = "strict";
      };
    };
  };

  systemd.services.docker-renovate.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "8h";
  };
}
