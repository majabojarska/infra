{ config, pkgs, ... }:

{
  services.borgmatic = {
    enable = true;
    enableConfigCheck = true;
    configurations."kubernetes" = {
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
      before_backup = [
        # Couple volume backup with ETCD state
        "${pkgs.k3s}/bin/k3s etcd-snapshot save --name borgmatic --etcd-snapshot-compress --etcd-snapshot-dir=/storage/kubernetes/snapshots"
        # Drain node and stop K3s
        "systemctl stop k3s.service"
        # Killall k3s https://docs.k3s.io/upgrades/killall#killall-script
        "${pkgs.k3s}/bin/k3s-killall.sh"
      ];
      after_actions = [
        # Restart k3s
        "systemctl restart k3s.service"
      ];

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 3;
      keep_yearly = 0;
    };
  };
}
