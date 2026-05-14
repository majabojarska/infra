{ pkgs, ... }:

{
  imports = [ ../../modules/system-packages-common.nix ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    zfs
  ];
}
