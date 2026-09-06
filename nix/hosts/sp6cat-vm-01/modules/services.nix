{ config, ... }:

{
  imports = [
    ./services/anubis.nix
    ./services/blog.nix
    ./services/borgbackup.nix
    ./services/chrony.nix
    ./services/copyparty.nix
    ./services/searx.nix
    ./services/redlib.nix
    ./services/uptime-kuma.nix
    ./services/fibo.nix
    ./services/llama-cpp.nix
    ./services/renovate.nix
    ./services/nginx.nix
    ./services/notifications.nix
    ./services/prometheus/prometheus.nix
    ./services/grafana/grafana.nix
    ./services/ntfy.nix
    ./services/dumbpad.nix
    ./services/stemdeck.nix
    ./services/traefik.nix
    (import ./services/vikunja.nix {
      hostname = "vikunja.${config.globals.cloudDomain}";
      port = config.hosts.sp6catVm01.ports.vikunja;
    })
  ];
}
