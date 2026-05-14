{ config, pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--data-dir /var/lib/rancher/k3s"
      # Needed for etcd to init properly, or convert from sqlite if k3s server was first started without this flag.
      # https://docs.k3s.io/datastore/ha-embedded?_highlight=cluster&_highlight=init#existing-single-node-clusters
      "--cluster-init"

      "--tls-san ${config.networking.hostName}.${config.networking.domain}" # https://docs.k3s.io/cli/server#k3s-server-cli-help

      # "--debug"
      # "-v=3"
      "--enable-pprof"
      # Disable built-in extension features
      # https://docs.k3s.io/installation/packaged-components?_highlight=disable#disabling-manifests
      "--disable=traefik"
      "--disable=local-storage"
      "--disable=metrics-server"
      "--disable-network-policy"
      # This is not equivalent to the metrics-server, it's just etcd metrics
      "--etcd-expose-metrics=true"

      # ETCD snapshotting
      # https://docs.k3s.io/cli/server#commonly-used-options
      ''--etcd-snapshot-schedule-cron="0 */8 * * *"''
      "--etcd-snapshot-retention=64"
      "--etcd-snapshot-compress"
      "--etcd-snapshot-dir=/storage/kubernetes/snapshots"

      # Cleanup old images more aggressively
      # https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
      "--kubelet-arg='--image-gc-low-threshold=20'"
      "--kubelet-arg='--image-gc-high-threshold=50'"

      # To handle the shitbox performance of the conservative CPU governor, for powersaving purposes.
      # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
      "--kube-controller-manager-arg='--leader-elect-lease-duration=60s'"
      "--kube-controller-manager-arg='--leader-elect-renew-deadline=40s'"
      "--kube-controller-manager-arg='--leader-elect-retry-period=5s'"
    ];
  };

  systemd.services."k3s-graceful-stop@${config.networking.hostName}" = {
    enable = true;
    description = "Ensures graceful workload stop upon k3s stop";

    wantedBy = [ "k3s.service" ];

    environment.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    unitConfig = {
      After = [ "k3s.service" ];
      BindsTo = [ "k3s.service" ];
    };

    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.k3s}/bin/kubectl uncordon %i";
      ExecStart = "${pkgs.coreutils}/bin/sleep inf";
      ExecStop = "${pkgs.k3s}/bin/kubectl drain %i --ignore-daemonsets --delete-emptydir-data --disable-eviction";
    };
  };
}
