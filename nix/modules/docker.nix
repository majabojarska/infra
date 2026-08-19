{ ... }:

{
  virtualisation.docker = {
    enable = true;

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
}
