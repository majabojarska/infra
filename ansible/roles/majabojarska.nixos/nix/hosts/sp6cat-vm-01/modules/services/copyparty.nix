{ config, pkgs, lib, ... }:
let
  healthchecks = import ../../../../modules/healthchecks.nix { inherit lib pkgs; };
in
{
  age.secrets = {
    "copyparty-pass-maja" = {
      file = ../../secrets/copyparty-pass-maja.age;
      mode = "0400";
      owner = "copyparty";
      group = "copyparty";
    };
    "copyparty-pass-baczek" = {
      file = ../../secrets/copyparty-pass-baczek.age;
      mode = "0400";
      owner = "copyparty";
      group = "copyparty";
    };
  };

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
      name = "meoooow MEEOOOWWW";
      name-url = "https://copyparty.${config.globals.cloudDomain}";
      site = "https://copyparty.${config.globals.cloudDomain}";
      i = "127.0.0.1";

      # use lists to set multiple values
      p = [
        config.sp6catVm01.ports.copyparty
      ];

      # num cores
      j = 1;

      # use booleans to set binary flags
      no-reload = false;
      #
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
      xff-src = "127.0.0.1"; # IP of the reverse proxy
      xff-hdr = "x-forwarded-for"; # HTTP header containing the real client's IP
      rproxy = 1;
      nid = true;
      usernames = true;
      no-dupe = true;
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

    volumes = {
      "/public" = {
        path = "${config.sp6catVm01.storage.wdUsbHddMountPath}/copyparty/public";
        # see `copyparty --help-accounts` for available options
        access = {
          r = "*";
          rw = [ "@users" ];
        };
        flags = {
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
        };
      };
      "/private" = {
        # share the contents of "/srv/copyparty"
        path = "${config.sp6catVm01.storage.wdUsbHddMountPath}/copyparty/private";
        # see `copyparty --help-accounts` for available options
        access = {
          rw = [ "@users" ];
        };
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
        };
      };
    };
    # you may increase the open file limit for the process
    openFilesLimit = 8192;

    package = pkgs.copyparty.override {
      # provides exiftool for bin/hooks/image-noexif.py
      extraPackages = [ pkgs.exiftool ];
    };
  };

  systemd.services.copyparty.serviceConfig.Restart = "always";

  system.preSwitchChecks = {
    copypartyLocalhostNoHttpError = healthchecks.curlHealthCheck {
      url = "http://127.0.0.1:${toString config.sp6catVm01.ports.copyparty}";
    };

    copypartyRespondsNoError = ''
      echo "Checking https://copyparty.${config.globals.cloudDomain}..."

      ${healthchecks.curlHealthCheck {
        url = "https://copyparty.${config.globals.cloudDomain}";
      }}
    '';
  };

}
