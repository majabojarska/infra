{ ... }:

{
  imports = [
    ../../modules/i18n.nix
    ../../modules/globals.nix

    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/storage.nix
    ./modules/networking.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/system.nix
    ./modules/users.nix
  ];
}
