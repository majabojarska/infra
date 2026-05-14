{ config, pkgs, ... }:

{
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  services.sanoid = {
    enable = true;
    datasets = {
      "storage/kubernetes" = {
        hourly = 24;
        daily = 3;
        weekly = 3;
        monthly = 3;
        # yearly = 12;
        autosnap = true;
        autoprune = true;
      };
      "storage/media" = {
        hourly = 24;
        daily = 3;
        weekly = 3;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  services.prometheus.exporters.zfs.enable = true;
}
