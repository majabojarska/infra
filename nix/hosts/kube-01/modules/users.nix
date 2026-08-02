{ config, pkgs, ... }:

let
  sshKeys = import ../../../modules/ssh-keys.nix;
in

{
  users.groups = {
    kubernetes = {
      gid = 10001;
    };
    media = {
      gid = 10002;
    };
    immich = {
      gid = 10003;
    };
    openwebrx = {
      gid = 10004;
    };
    arr = {
      gid = 10006;
    };
    zigbee = {
      gid = 10007;
    };
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = sshKeys.maja;
    };

    # Human-like users
    maja = {
      isNormalUser = true;
      description = "maja";
      extraGroups = [
        "networkmanager"
        "wheel"
        "media"
        "kubernetes"
        "docker"
        "immich"
      ];
      openssh.authorizedKeys.keys = sshKeys.maja;
    };

    # Service users
    kubernetes = {
      isSystemUser = true;
      group = "kubernetes";
      uid = 10001;
      description = "Generic Kubernetes";
    };
    immich = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "immich";
      uid = 10003;
      description = "Immich";
      extraGroups = [
        "kubernetes"
        "video" # /dev/dri/cardX
        "render" # /dri/renderX
      ];
    };
    openwebrx = {
      isSystemUser = true;
      # isNormalUser = false;
      uid = 10004;
      group = "openwebrx";
      extraGroups = [ "plugdev" ];
    };
    arr = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "arr";
      uid = 10006;
      description = "Arr stack";
      extraGroups = [
        "kubernetes"
        "media"
      ];
    };
    zigbee = {
      isSystemUser = true;
      group = "zigbee";
      uid = 10007;
      description = "ZigBee";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "maja" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];
}
