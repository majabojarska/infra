{ config, ...}:
{
  # https://github.com/9001/copyparty?tab=readme-ov-file#nixos-module
  services.copyparty = {
    enable = true;
    # the user to run the service as
    user = "copyparty";
    # the group to run the service as
    group = "copyparty";
    # directly maps to values in the [global] section of the copyparty config.
    # see `copyparty --help` for available options
    settings = {
      i = "127.0.0.1";
      # use lists to set multiple values
      p = [
        8005
      ];
      # use booleans to set binary flags
      no-reload = false;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
      xff-src = "127.0.0.1"; # IP of the reverse proxy
      xff-hdr = "x-forwarded-for"; # HTTP header containing the real client's IP
      rproxy = 1;
    };

    # create users
    accounts = {
      maja = {
        passwordFile = config.age.secrets."copyparty-pass-maja".path;
      };
      baczek = {
        passwordFile = config.age.secrets."copyparty-pass-baczek".path;
      };
    };

    # create a group
    groups = {
      admins = [
        "maja"
      ];
      users = [
        "maja"
        "baczek"
      ];
    };

    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };
}