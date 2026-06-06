{ pkgs, ... }:

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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBch2rzzVEnWcUbHJctteozpAFyJYXnd8wMC7DWXS9rL" # FP5
        ];
      };
      www-data = {
        isNormalUser = true;
        description = "Deploys WWW data";
        group = "www-data";
        home = "/var/www";
        homeMode = "750";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZU7nJ9AUBywX6+icIJ3t4NCEoIbnEOzEfGxYYSX5dI" # Bitwarden: SSH key vps-01 deploy-blog
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8 majabojarska98@gmail.com" # x260
        ];
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
