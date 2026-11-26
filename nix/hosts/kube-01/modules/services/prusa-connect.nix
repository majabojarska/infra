{ config, ... }:

let
  storageRoot = "${config.hosts.kube01.storageMirror}/services/prusa-connect";
  configRoot = "${storageRoot}/config";
  storagePath = "${storageRoot}/storage";
  dataPath = "${storageRoot}/data";
  filesPath = "${storageRoot}/files";
  prusaConnectUid = toString config.users.users.prusaconnect.uid;
  prusaConnectGid = toString config.users.groups.prusaconnect.gid;
in
{
  environment.etc."prusa-connect/config.yaml" = {
    user = "prusaconnect";
    group = "prusaconnect";
    mode = "0440";
    text = ''
    core:
      api:
        addr: ":8080"
      log:
        level: info
        format: text

    resources:
      storage:
        local:
          type: filesystem
          config:
            root: ./storage
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.prusa-connect = {
      image = "ghcr.io/prusa3d/prusa-connect:0.1.0-beta.2@sha256:8ab946744acaaf48823f7931382f620b4acb42ae6f31c7efbf384073215c336f";
      autoStart = true;
      user = "${prusaConnectUid}:${prusaConnectGid}";
      ports = [
        "127.0.0.1:${toString config.hosts.kube01.ports.prusaConnect}:8080"
      ];
      volumes = [
        "${config.environment.etc."prusa-connect/config.yaml".source}:/config/config.yaml:ro"
        "${configRoot}:/config/config.d"
        "${storagePath}:/storage"
        "${dataPath}:/data"
        "${filesPath}:/files"
      ];
      extraOptions = [
        "--read-only"
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges:true"
        "--tmpfs=/tmp"
        "--log-driver=json-file"
        "--log-opt=max-size=10m"
        "--log-opt=max-file=5"
      ];
    };
  };

  systemd.services.docker-prusa-connect.serviceConfig.Restart = "on-failure";

  systemd.tmpfiles.rules = [
    "d ${storageRoot} 0750 prusaconnect prusaconnect -"
    "d ${configRoot} 0750 prusaconnect prusaconnect -"
    "d ${storagePath} 0750 prusaconnect prusaconnect -"
    "d ${dataPath} 0750 prusaconnect prusaconnect -"
    "d ${filesPath} 0750 prusaconnect prusaconnect -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.prusa-connect = {
      rule = "Host(`prusa-connect.home.majabojarska.dev`)";
      service = "prusa-connect";
      tls = {
        certResolver = "letsencrypt";
        domains = [ { main = "prusa-connect.home.majabojarska.dev"; } ];
      };
    };
    services.prusa-connect.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.hosts.kube01.ports.prusaConnect}"; }
    ];
  };
}
