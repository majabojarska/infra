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
}
