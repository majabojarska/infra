{ pkgs, ... }:

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
    jellyfin = {
      gid = 10005;
    };
    arr = {
      gid = 10006;
    };
    zigbee = {
      gid = 10007;
    };
  };

  users.users = {
    # Human-like users
    maja = {
      isNormalUser = true;
      description = "maja";
      extraGroups = [
        "networkmanager"
        "wheel"
        "media"
        "kubernetes"
      ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBch2rzzVEnWcUbHJctteozpAFyJYXnd8wMC7DWXS9rL" # FP5
      ];
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
    jellyfin = {
      isSystemUser = true;
      # isNormalUser = true;
      group = "jellyfin";
      uid = 10005;
      description = "Jellyfin";
      extraGroups = [
        "kubernetes"
        "media"
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
