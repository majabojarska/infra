{ config, ... }:

{
  imports = [
    ./services/anubis.nix
    ./services/blog.nix
    ./services/borgbackup.nix
    ./services/chrony.nix
    ./services/copyparty.nix
    ./services/docker.nix
    ./services/uptime-kuma.nix
    ./services/fibo.nix
    ./services/nginx.nix
    ./services/redlib.nix
    ./services/prometheus.nix
    ./services/prometheus-exporter.nix
    ./services/grafana.nix
    ./services/traefik.nix
    (import ./services/vikunja.nix {
      hostname = "vikunja.${config.globals.cloudDomain}";
      port = 3456;
    })
  ];
}
