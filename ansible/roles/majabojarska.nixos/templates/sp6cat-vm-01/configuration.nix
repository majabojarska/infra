{ ... }:

{
  imports = [
    ./secrets.nix
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/i18n.nix
    ./modules/networking.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/system.nix
    ./modules/users.nix
  ];
}
