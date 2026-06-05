{ ... }:

{
  imports = [
    ./services/anubis.nix
    ./services/blog.nix
    ./services/borgbackup.nix
    ./services/chrony.nix
    ./services/copyparty.nix
    ./services/docker.nix
    ./services/fibo.nix
    ./services/nginx.nix
    ./services/traefik.nix
    (import ./services/vikunja.nix {
      hostname = "vikunja.cloud.majabojarska.dev";
      port = 3456;
    })
  ];
}
