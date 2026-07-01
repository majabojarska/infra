{ config, pkgs, ... }:

let
  sshKeys = import ../../../modules/ssh-keys.nix;
in

{

  users = {
    groups = {
      www-data = {
        members = [
          "nginx"
          "maja"
        ];
      };
    };
    users = {
      maja = {
        isNormalUser = true;
        description = "maja";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        packages = with pkgs; [ ];
        openssh.authorizedKeys.keys =sshKeys.maja;
      };
      www-data = {
        isNormalUser = true;
        description = "Deploys WWW data";
        group = "www-data";
        home = "/var/www";
        homeMode = "750";
        openssh.authorizedKeys.keys =sshKeys."www-data";
      };
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
      value = "20000";
    }
  ];
}
