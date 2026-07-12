{ pkgs, ... }:

{
  imports = [ ../../../modules/system-packages-common.nix ];

  environment.systemPackages = with pkgs; [
    busybox
    copyparty
    wireguard-tools
    smartmontools
    sqlite-utils
    zfs
  ];
}
