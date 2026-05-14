# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports = [
    ./secrets.nix
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/i18n.nix
    ./modules/networking.nix
    ./modules/packages.nix
    ./modules/platform-services.nix
    ./modules/system.nix
    ./modules/users.nix
  ];
}
