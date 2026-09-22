{ lib, config, pkgs, ... }:

let
  containerNetworks = lib.unique (lib.concatMap
    (container: lib.concatMap
      (option:
        if lib.hasPrefix "--network=" option
        then [ (lib.removePrefix "--network=" option) ]
        else [ ])
      (container.extraOptions or [ ]))
    (lib.attrValues config.virtualisation.oci-containers.containers));

  networkServices = lib.listToAttrs (map
    (network: {
      name = "docker-${network}-network";
      value = {
        description = "Create Docker network for ${network}";
        wantedBy = [ "multi-user.target" ];
        requires = [ "docker.service" ];
        after = [ "docker.service" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect ${network} >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create ${network} >/dev/null'
          '';
          RemainAfterExit = true;
        };
      };
    })
    containerNetworks);

  containerNetworkDependencies = lib.listToAttrs (lib.concatMap
    (containerName:
      let
        container = config.virtualisation.oci-containers.containers.${containerName};
        networks = lib.concatMap
          (option:
            if lib.hasPrefix "--network=" option
            then [ (lib.removePrefix "--network=" option) ]
            else [ ])
          (container.extraOptions or [ ]);
      in
      lib.optional (networks != [ ]) {
        name = "docker-${containerName}";
        value = {
          requires = map (network: "docker-${network}-network.service") networks;
          after = map (network: "docker-${network}-network.service") networks;
        };
      })
    (lib.attrNames config.virtualisation.oci-containers.containers));

in
{
  options.dataRoot = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Optional Docker data directory.";
  };

  config = {
    virtualisation.docker = {
      enable = true;

      daemon.settings = lib.mkIf (config.dataRoot != null) {
        "data-root" = config.dataRoot;
      };

      autoPrune = {
        enable = true;
        dates = "hourly";
        # So that the prune service doesn't run on boot,
        # which would wipe images for containers that are about to start.
        allVolumes = {
          enable = true;
        };
        randomizedDelaySec = "5min";
        flags = [
          "--all"
          "--volumes"
        ];
      };
    };

    systemd.tmpfiles.rules = lib.optional (config.dataRoot != null)
      "d ${config.dataRoot} 0755 root root -";

    systemd.services = networkServices // containerNetworkDependencies;
  };
}
