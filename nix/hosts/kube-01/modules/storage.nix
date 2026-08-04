{ config, pkgs, ... }:

{
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  # Bind mount the "kubernetes" dataset mountpoint to the future path
  fileSystems."/storage/kubernetes" = {
    device = "/storage/mirror";
    fsType = "none";
    options = [ "bind" ];
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
