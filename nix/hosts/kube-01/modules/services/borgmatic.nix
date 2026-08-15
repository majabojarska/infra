{
  config,
  lib,
  pkgs,
  ...
}:
let
  ntfy-tag = "backups";
in
{
  age = {
    secrets = {
      "borgmatic-kubernetes-enc-pass" = {
        file = ../../secrets/borgmatic-kubernetes-enc-pass.age;
        mode = "0400";
      };
      "ntfy-token" = {
        file = ../../secrets/ntfy-token.age;
        mode = "0400";
      };
    };
  };

  services.borgmatic = {
    enable = true;
    enableConfigCheck = true;
    configurations."mirror" =
      let
        stop-docker-units-script = pkgs.writeText "borgmatic-stop-docker-units.sh" ''
          set -euo pipefail

          units_file=/run/borgmatic-docker-units
          systemctl list-units --type=service --state=active --no-legend --plain "docker-*.service" \
            | while read -r unit _; do
                printf "%s\n" "$unit"
              done > "$units_file"

          if [ -s "$units_file" ]; then
            systemctl stop $(cat "$units_file")
          fi
        '';
        start-docker-units-script = pkgs.writeText "borgmatic-start-docker-units.sh" ''
          set -euo pipefail

          units_file=/run/borgmatic-docker-units
          if [ -s "$units_file" ]; then
            systemctl start $(cat "$units_file")
          fi
          rm -f "$units_file"
        '';
      in
      {
      checks = [
        {
          name = "repository";
          frequency = "1 week";
        }
        {
          name = "archives";
          frequency = "1 week";
        }
      ];

      # zfs = { }; # Enables ZFS in borgmatic # TODO:
      source_directories = [
        # Persistent Volumes
        "/storage/mirror/"
      ];
      exclude_patterns = [
        "*/.zfs" # Contains ZFS snapdir, backing this up would be redundant.
        "vps-01-backups"
        "/storage/kubernetes/vps-01-backups"
      ];
      repositories = [
        {
          label = "kubernetes-offsite-vps-01";
          path = "ssh://borg@${config.globals.sp6catVm01HswroDomain}/mnt/wd-usb-hdd/borg/kube-01/kubernetes";
        }
      ];
      exclude_if_present = [ ".nobackup" ];
      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${
        config.age.secrets."borgmatic-kubernetes-enc-pass".path
      }";
      relocated_repo_access_is_ok = true;
      compression = "auto,zstd,10";

      commands = [
        {
          before = "action";
          when = [ "create" ];
          run = [
            # Persist currently active docker systemd service units and stop that set.
            "${pkgs.bash}/bin/bash ${stop-docker-units-script}"
          ];
        }
        {
          after = "action";
          when = [ "create" ];
          run = [
            # Start docker systemd service units that were active before backup.
            "${pkgs.bash}/bin/bash ${start-docker-units-script}"
          ];
        }
      ];

      ntfy = {
        topic = "backups";
        server = "https://ntfy.${config.globals.cloudDomain}";
        access_token = "{credential file ${config.age.secrets."ntfy-token".path}}";

        start = {
          title = "Borgmatic backup started";
          message = "${config.networking.hostName} Borgmatic backup 'mirror' started.";
          priority = "min";
          tags = ntfy-tag;
          };
        finish = {
          title = "Borgmatic backup finished";
          message = "${config.networking.hostName} Borgmatic backup 'mirror' finished.";
          priority = "min";
          tags = ntfy-tag;
        };
        fail = {
          title = "Borgmatic backup failed";
          message = "${config.networking.hostName} Borgmatic backup 'mirror' failed.";
          priority = "max";
          tags = ntfy-tag;
        };
        states = [
          "fail"
          "start"
          "finish"
        ];
      };

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 3;
      keep_yearly = 0;
    };

  };
}
