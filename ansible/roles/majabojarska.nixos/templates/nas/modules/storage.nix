{ ... }:

{

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  services.sanoid = {
    enable = true;
    datasets = {
      "storage/data" = {
        hourly = 24;
        daily = 3;
        weekly = 3;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
      "storage/backup" = {
        hourly = 24;
        daily = 3;
        weekly = 3;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
    };
  };
}
