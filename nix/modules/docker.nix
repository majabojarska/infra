{ lib, config, ... }:

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
      };
    };

    systemd.tmpfiles.rules = lib.optional (config.dataRoot != null)
      "d ${config.dataRoot} 0755 root root -";
  };
}
