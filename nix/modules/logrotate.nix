{ ... }:

{
  services.logrotate = {
    enable = true;

    settings = {
      header = {
        daily = true;
        maxsize = "100M";
        rotate = 7;
        compress = true;
      };
    };
  };

  services.journald.extraConfig = ''
    MaxRetentionSec=2weeks
    SystemMaxUse=500M
    SystemKeepFree=1G
  '';
}
