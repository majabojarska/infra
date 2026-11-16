{
  config,
  ...
}:
let
  pathPatreonDl = "/storage/mirror/services/patreon-dl";
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.patreon-dl = {
      image = "majabojarska/patreon-dl:2026-11-15@sha256:323b185ffeea36d9575899fbd5704aac7c6c340232af6567f025fd06aca369f7";
      autoStart = true;
      user = "${toString config.users.users.patreon-dl.uid}:${toString config.users.groups.patreon-dl.gid}";
      cmd = [
        "/app/bin/patreon-dl-server.js"
        "--data-dir"
        "/data"
        "--port"
        "3000"
      ];
      ports = [
        "127.0.0.1:${toString config.hosts.kube01.ports.patreon-dl}:3000"
      ];
      volumes = [ "${pathPatreonDl}:/data" ];
    };
  };

  systemd.services.docker-patreon-dl.serviceConfig.Restart = "on-failure";

  systemd.tmpfiles.rules = [
    "d ${pathPatreonDl} 0750 ${toString config.users.users.patreon-dl.uid} ${
      toString config.users.groups.patreon-dl.gid
    } -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.patreon-dl = {
      rule = "Host(`patreon.${config.globals.homeDomain}`)";
      service = "patreon-dl";
      tls = {
        certResolver = "letsencrypt";
        domains = [ { main = "patreon.${config.globals.homeDomain}"; } ];
      };
    };

    services.patreon-dl.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.hosts.kube01.ports.patreon-dl}"; }
    ];
  };
}
