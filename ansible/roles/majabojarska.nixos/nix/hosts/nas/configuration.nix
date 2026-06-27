{ config, lib, pkgs, ... }: {
  imports = [
    ../../modules/globals.nix
    ../../modules/i18n.nix
    ../../modules/system-packages-common.nix
  ];

  users.users = {
    maja = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "";
    };
  };

  environment.systemPackages = with pkgs; [
    python3
  ];

  system.stateVersion = "26.05";
}
