{ config, ... }:

{
  imports = [
    ./services/anubis.nix
    ./services/blog.nix
    ./services/borgbackup.nix
    ./services/chrony.nix
    ./services/copyparty.nix
    ./services/searx.nix
    ./services/docker.nix
    ./services/uptime-kuma.nix
    ./services/fibo.nix
    ./services/nginx.nix
    ./services/notifications.nix
    ./services/redlib.nix
    ./services/prometheus/prometheus.nix
    ./services/grafana/grafana.nix
    ./services/ntfy.nix
    ./services/traefik.nix
    (import ./services/vikunja.nix {
      hostname = "vikunja.${config.globals.cloudDomain}";
      port = 3456;
    })
  ];
}
