{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/i18n.nix
    ../../modules/users.nix
    ../../modules/ssh.nix

    ./modules/system.nix
    ./modules/storage.nix
    ./modules/packages.nix
  ];

  system.stateVersion = "26.05";
}
