{
  config,
  lib,
  pkgs,
  ...
}:

{
  age = {
    secrets = {
      "borgmatic-kubernetes-enc-pass" = {
        file = ../secrets/borgmatic-kubernetes-enc-pass.age;
        mode = "0400";
      };
      "ntfy-token" = {
        file = ../secrets/ntfy-token.age;
        mode = "0400";
      };
    };
  };

  services.borgmatic = {
    enable = true;
    enableConfigCheck = true;
    configurations."kubernetes" = {
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
        # K3s state
        # "/var/lib/rancher/k3s/server/db/snapshots"
        # "/var/lib/rancher/k3s/server/token"
        # Persistent Volumes
        "/storage/kubernetes/"
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
          after = "action";
          when = [ "create" ];
          run = [
            # Restart k3s
            "systemctl restart k3s.service"
          ];
        }
        {
          before = "action";
          when = [ "create" ];
          run = [
            # Couple volume backup with ETCD state
            "${pkgs.k3s}/bin/k3s etcd-snapshot save --name borgmatic --etcd-snapshot-compress --etcd-snapshot-dir=/storage/kubernetes/snapshots"
            # Drain node and stop K3s
            "systemctl stop k3s.service"
            # Killall k3s https://docs.k3s.io/upgrades/killall#killall-script
            "${pkgs.k3s}/bin/k3s-killall.sh"
          ];
        }
      ];

      ntfy = {
        topic = "backups";
        server = "https://ntfy.${config.globals.cloudDomain}";
        access_token = "{credential file ${config.age.secrets."ntfy-token".path}}";

        start = {
          title = "Borgmatic backup started";
          message = "Borgmatic backup {repository} ({configuration_filename}) started on $(hostname) at $(date).";
          priority = "min";
          tags = "backups";
        };
        finish = {
          title = "Borgmatic backup finished";
          message = "Borgmatic backup {repository} ({configuration_filename}) finished on $(hostname) at $(date).";
          priority = "min";
          tags = "backups";
        };
        fail = {
          title = "Borgmatic backup failed";
          message = "Borgmatic backup {repository} ({configuration_filename}) failed on $(hostname) at $(date).";
          priority = "max";
          tags = "backups";
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

  systemd.timers.borgmatic.timerConfig = {
    OnCalendar = lib.mkForce "*-*-* 05:00:00";
    Persistent = true;
  };
}
