{ pkgs, ... }:

{
  users.users = {
    maja = {
      isNormalUser = true;
      description = "maja";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW+jmBmPtDv+Bw21i9J4p/pZPdM7SggxBF9FGOWXSM8"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAV1AUyhqMQldeCXCH/a2a7vwKxyPMyaqZT9w82elKE"
      ];
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
}
