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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjpxvbmIPz4MXmkbLjwCJN4MJ1Wg6TWgzi4eK/MuyNd majabojarska98@gmail.com"
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
