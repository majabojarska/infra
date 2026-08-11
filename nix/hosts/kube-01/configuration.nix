# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ ... }:
{
  imports = [
    ../../modules/globals.nix
    ../../modules/logrotate.nix
    ../../modules/shell-zsh-fzf.nix
    ../../modules/docker.nix

    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/system.nix
    ./modules/networking.nix
    ./modules/storage.nix
    ./modules/services.nix
    ./modules/packages.nix
    ./modules/users.nix
  ];
}
